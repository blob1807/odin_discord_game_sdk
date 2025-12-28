package cpp_example

import "base:runtime"
import "core:log"
import "core:strings"
import "core:c/libc"
import "core:time"
import os "core:os/os2"

import discord "./../.."


Bitmap_Image_Header :: struct {
	header_size: u32,
	width:       i32,
	height:      i32,
	planes:      u16,
	bpp:         u16,
	_:           u64,
	hres:        u32,
	vres:        u32,
	_:           u64,
}

Bitmap_File_Header :: struct {
	magic:  [2]u8,
	size:   u32,
	_:      u32,
	offset: u32
}

DEFAULT_BITMAP_IMAGE_HEADER :: Bitmap_Image_Header {
	header_size = size_of(Bitmap_Image_Header),
	width       = 0,
	height      = 0,
	planes      = 1,
	bpp         = 32,
	hres        = 2835,
	vres        = 2835
}

DEFAULT_BITMAP_FILE_HEADER :: Bitmap_File_Header {
	magic  = "BM",
	size   = 0,
	offset = size_of(Bitmap_Image_Header) + size_of(Bitmap_File_Header)
}


Discord_State :: struct {
	current_user: discord.User,
	core: ^discord.Core,
	ctx: runtime.Context,

	activities:    ^discord.ActivityManager,
	users:         ^discord.UserManager,
	lobbies:       ^discord.LobbyManager,
	relationships: ^discord.RelationshipManager,
	images:        ^discord.ImageManager,
}


main :: proc() {
	context.logger = log.create_console_logger()

	state: Discord_State
	state.core = new(discord.Core)
	state.ctx = context

	params := discord.new_params(418559331265675294, .Default, &state)
	defer discord.destroy_params(&params)

	params.user_events.on_current_user_update = proc "system" (event_data: rawptr) {
		state := (^Discord_State)(event_data); context = state.ctx

		state.users->get_current_user(&state.current_user)
		log.infof("Current user updated: %s#%s", state.current_user.username, state.current_user.discriminator)

		state.users->get_user(
			130050050968518656, state, 
			proc "system" (callback_data: rawptr, result: discord.Result, user: ^discord.User) {
				state := (^Discord_State)(callback_data); context = state.ctx
				if result == .Ok {
					log.infof("Get %s", user.username)
				} else {
					log.error("Failed to get David:", result)
				}

		})

		handle := discord.ImageHandle {
			id   = state.current_user.id,
			type = .User,
			size = 256,
		}

		state.images->fetch(
			handle, true, state, 
			proc "system" (callback_data: rawptr, result: discord.Result, handle_result: discord.ImageHandle) {
				state := (^Discord_State)(callback_data); context = state.ctx
				if result != .Ok {
					log.error("Failed fetching avatar:", result)
					return
				}
				
				img_data, dims := discord.get_image_data(state.images, handle_result)

				img_header := DEFAULT_BITMAP_IMAGE_HEADER 
				img_header.width  = i32(dims.width)
				img_header.height = i32(dims.height)

				file_header := DEFAULT_BITMAP_FILE_HEADER
				file_header.size = file_header.offset + size_of(Bitmap_File_Header) + size_of(Bitmap_Image_Header)

				fp, err := os.open("avatar.bmp", {.Write, .Create, .Trunc})
				if err != nil {
					log.error("Fail to open \"avatar.bmp\":", err)
					return
				}
				defer os.close(fp)
				defer os.flush(fp)

				_, err = os.write_ptr(fp, &file_header, size_of(Bitmap_File_Header))
				if err != nil {
					log.error("Fail to write bmp file header. (err ", err, ")", sep="")
					return
				}
				_, err = os.write_ptr(fp, &img_header, size_of(Bitmap_Image_Header))
				if err != nil {
					log.error("Fail to write bmp image header:", err)
					return
				}
				_, err = os.write(fp, img_data)
				if err != nil {
					log.error("Fail to write bmp image data:", err)
				}
			}
		)
	}


	params.activity_events.on_activity_join = proc "system" (event_data: rawptr, secret: cstring) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.info("Join", secret)
	}
	params.activity_events.on_activity_spectate = proc "system" (event_data: rawptr, secret: cstring) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.info("Spectate", secret)
	}
	params.activity_events.on_activity_join_request = proc "system" (event_data: rawptr, user: ^discord.User) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Spectate %s", user.username)
	}
	params.activity_events.on_activity_invite = proc "system" (event_data: rawptr, type: discord.ActivityActionType, user: ^discord.User, activity: ^discord.Activity) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Invite %s", user.username)
	}


	params.lobby_events.on_lobby_update = proc "system" (event_data: rawptr, lobby_id: i64) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.info("Lobby update", lobby_id)
	}
	params.lobby_events.on_lobby_delete = proc "system" (event_data: rawptr, lobby_id: i64, reason:  u32) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Lobby delete %v (reason %v)", lobby_id, reason)
	}
	params.lobby_events.on_member_connect = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Lobby member connect %v User ID %v", lobby_id, user_id)
	}
	params.lobby_events.on_member_update = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Lobby member update %v User ID %v", lobby_id, user_id)
	}
	params.lobby_events.on_member_disconnect = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Lobby member disconnect %v User ID %v", lobby_id, user_id)
	}

	params.lobby_events.on_lobby_message = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64, data: [^]byte, data_length: u32) {
		state := (^Discord_State)(event_data); context = state.ctx
		
		log.infof("Lobby message %v from %v of length %v bytes.", lobby_id, user_id, data_length)
		log.info("\t", string(data[:data_length]))

		buf: discord.MetadataValue
		key: discord.MetadataKey
		copy(key[:], "foo")
		
		state.lobbies->get_lobby_metadata_value(lobby_id, key, &buf)
		log.infof("Metadata for key foo is %s", buf)
	}

	params.lobby_events.on_speaking = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64, speaking: bool) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("User %v %v speaking.", user_id, speaking ? "is" : "isn't")
	}


	params.relationship_events.on_relationship_update = proc "system" (event_data: rawptr, relationship: ^discord.Relationship) {
		state := (^Discord_State)(event_data); context = state.ctx
		log.infof("Relationship with %s updated!", relationship.user.username)
	}


	result := discord.Create(discord.VERSION, params, &state.core)
	if result != .Ok {
		log.error("Failed to instantiate discord core:", result)
		return
	}
	defer state.core->destroy()

	state.core->set_log_hook(.Debug, &state.ctx, discord.discord_logger)

	state.activities    = state.core->get_activity_manager()
	state.lobbies       = state.core->get_lobby_manager()
	state.relationships = state.core->get_relationship_manager()
	state.images        = state.core->get_image_manager()
	state.users         = state.core->get_user_manager()

	state.activities->register_command("run/command/foo/bar/baz/here.exe")
	state.activities->register_steam(123123321)

	activity: discord.Activity
	copy(activity.details[:], "Fruit Tarts")
	copy(activity.state[:], "Pop Snacks")
	copy(activity.assets.small_image[:], "the")
	copy(activity.assets.small_text[:],  "i mage")
	copy(activity.assets.large_image[:], "the")
	copy(activity.assets.large_image[:], "u mage")
	copy(activity.secrets.join[:], "join secret")
	activity.party.size = { current_size = 1, max_size = 5 }
	copy(activity.party.id[:], "party id")
	activity.party.privacy = .Public
	activity.type = .Playing
	state.activities->update_activity(
		&activity, &state,
		proc "system" (callback_data: rawptr, result: discord.Result) {
			state := (^Discord_State)(callback_data); context = state.ctx
			if result == .Ok { log.info("Succeeded updating activity!") }
			else { log.error("Failed updating activity!")}
		}
	)

	lobby: ^discord.LobbyTransaction
	state.lobbies->get_lobby_create_transaction(&lobby)
	lobby->set_capacity(2)
	key: discord.MetadataKey
	value: discord.MetadataValue
	copy(key[:], "foo"); copy(value[:], "bar");
	lobby->set_metadata(key, value)
	copy(key[:], "baz"); copy(value[:], "bat");
	lobby->set_metadata(key, value)
	lobby->set_type(.Public)
	state.lobbies->create_lobby(
		lobby, &state,
		proc "system" (callback_data: rawptr, result: discord.Result, lobby: ^discord.Lobby) {
			state := (^Discord_State)(callback_data); context = state.ctx
			if result != .Ok {
				log.error("Failed creating lobby:", result)

			} else {
				log.infof("Created lobby with secret %s", lobby.secret)
				buf: [234]byte
				copy(buf[:], "Hello")
				state.lobbies->send_lobby_message (
					lobby.id, raw_data(buf[:]), len(buf), state,
					proc "system" (callback_data: rawptr, result: discord.Result) {
						state := (^Discord_State)(callback_data); context = state.ctx
						log.info("Sent message. Result:", result)
					}
				)
			}

			query: ^discord.LobbySearchQuery
			state.lobbies->get_search_query(&query)
			query->limit(1)
			state.lobbies->search(
				query, &state,
				proc "system" (callback_data: rawptr, result: discord.Result) {
					state := (^Discord_State)(callback_data); context = state.ctx
					if result != .Ok {
						log.error("Lobby search failed:", result)
						return
					}

					count: i32
					state.lobbies->lobby_count(&count)
					sb := strings.builder_make()
					defer strings.builder_destroy(&sb)

					strings.write_string(&sb, "Lobby search succeeded with ")
					strings.write_int(&sb, int(count))
					strings.write_string(&sb, " lobbies.\n")

					for i in 0..<count {
						id: discord.LobbyId
						state.lobbies->get_lobby_id(i, &id)
						strings.write_byte(&sb, ' ')
						strings.write_int(&sb, int(id))
						strings.write_byte(&sb, '\n')
					}
					strings.pop_byte(&sb)

					log.info(strings.to_string(sb))
				}
			)

		}
	)

	@static interrupted: bool
	libc.signal(libc.SIGINT, proc "c" (i32) { interrupted = true })
	libc.signal(libc.SIGILL, proc "c" (i32) { interrupted = true })

	for !interrupted {
		state.core->run_callbacks()
		time.sleep(time.Millisecond * 16)
	}
}

require :: proc(r: discord.Result, exp := #caller_expression(r), loc := #caller_location) { 
	log.assertf( r == .Ok, "Result Error: %v %v", r, exp, loc=loc)
}