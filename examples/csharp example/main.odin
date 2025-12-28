package csharp_example

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:log"
import "core:time"
import "core:c/libc"
import "core:strconv"
import "core:math/rand"

import discord "./../.."


// Request user's avatar data. Sizes can be powers of 2 between 16 and 2048
fetch_avatar :: proc(userID: discord.UserId) {
	image_handle := discord.ImageHandle {
		type = .User,
		id = userID,
		size = 128
	}
	state.images->fetch(
		image_handle, false, nil,
		proc "system" (callback_data: rawptr, result: discord.Result, handle_result: discord.ImageHandle) {
			context = state.ctx
			if result == .Ok {
				// You can also use GetTexture2D within Unity.
				// These return raw RGBA.

				dims: discord.ImageDimensions
				require( state.images->get_dimensions(handle_result, &dims) )

				data := make([]byte, dims.height * dims.width * 4)
				defer delete(data)

				require( state.images->get_data(handle_result, raw_data(data), u32(len(data))) )

				fmt.printfln("image updated {0} {1}", handle_result.id, len(data))

			} else {
				fmt.printfln("image error {0}", handle_result.id)
			}
		}
	
	)
}


// Update user's activity for your game.
// Party and secrets are vital.
// Read https://discordapp.com/developers/docs/rich-presence/how-to for more details.
update_activity :: proc (lobby: ^discord.Lobby) {

	activity := discord.Activity {
		timestamps = { start = 5, end = 6, },
		instance = true,
	}
	activity.party.size.max_size = i32(lobby.capacity)

	copy(activity.state[:],   "olleh")
	copy(activity.details[:], "foo details")
	copy(activity.assets.large_image[:], "foo largeImageKey")
	copy(activity.assets.large_text[:],  "foo largeImageText")
	copy(activity.assets.small_image[:], "foo smallImageKey")
	copy(activity.assets.small_text[:],  "foo smallImageText")
	strconv.write_int(activity.party.id[:], lobby.id, 10)
	require( state.lobbies->member_count(lobby.id, &activity.party.size.current_size) )
	require( state.lobbies->get_lobby_activity_secret(lobby.id, &activity.secrets.join) )

	state.activities->update_activity(
		&activity, nil,
		proc "system" (callback_data: rawptr, result: discord.Result) {
			context = state.ctx
			fmt.println("Update Activity", result)

			// Send an invite to another user for this activity.
			// Receiver should see an invite in their DM.
			// Use a relationship user's ID for this.
			/*
			invite_result_callback :: proc "system" (callback_data: rawptr, result: discord.Result) {
				context = state.ctx
				fmt.println("Invite", result)
			}
			state.activities->send_invite(364843917537050624, .Join, "", state.activities, InviteResultCallback)
			*/
		}
	)
}


State :: struct {
	current_user: discord.User,
	core: ^discord.Core,
	ctx: runtime.Context,
	using managers: discord.Managers,
}

state: State

main :: proc() {
	state.core = new(discord.Core)
	state.ctx = context

	events_arena: mem.Arena
	mem.arena_init(&events_arena, make([]byte, discord.PARAMA_EVENTS_SIZE))
	defer delete(events_arena.data)

	// Use your client ID from Discord's developer site.
	params: discord.CreateParams
	discord.init_params(&params, 418559331265675294, .Default, state.core, mem.arena_allocator(&events_arena))
	assert(params.achievement_events != nil)
	defer discord.free_params(&params)
	
	result := discord.Create(discord.VERSION, &params, &state.core)
	if result != .Ok {
		log.error("Failed to instantiate discord core:", result)
		return
	}
	defer state.core->destroy()
	
	state.core->set_log_hook (
		.Debug, nil, 
		proc "system" (hook_data: rawptr, level: discord.LogLevel, message: cstring) {
			context = state.ctx
			fmt.printfln("Log[%v] %v", level, message)
		}
	)
	state.managers = discord.make_managers(state.core)


	// Get the current locale. This can be used to determine what text or audio the user wants.
	locale: discord.Locale
	state.applications->get_current_locale(&locale)
	fmt.printfln("Current Locale: %s", locale)
	// Get the current branch. For example alpha or beta.
	branch: discord.Branch
	state.applications->get_current_branch(&branch)
	fmt.printfln("Current Branch: %s", branch)
	// If you want to verify information from your game's server then you can
	// grab the access token and send it to your server.
	//
	// This automatically looks for an environment variable passed by the Discord client,
	// if it does not exist the Discord client will focus itself for manual authorization.
	//
	// By-default the SDK grants the identify and rpc scopes.
	// Read more at https://discordapp.com/developers/docs/topics/oauth2
	/*state.applications->get_oauth2_token (
		nil, 
		proc "system" (callback_data: rawptr, result: discord.Result, oauth2_token: ^discord.OAuth2Token) {
			context = state.ctx
			fmt.printfln("Access Token %v", oauth2_token)
		}
	)*/

	// Received when someone accepts a request to join or invite.
	// Use secrets to receive back the information needed to add the user to the group/party/match
	params.activity_events.on_activity_join = proc "system" (event_data: rawptr, secret: cstring) {
		context = state.ctx
		fmt.println("OnJoin", secret)

		secret_buf: discord.LobbySecret
		copy(secret_buf[:], string(secret))

		state.lobbies->connect_lobby_with_activity_secret (
			secret_buf, nil ,
			proc "system" (callback_data: rawptr, result: discord.Result, lobby: ^discord.Lobby) {
				context = state.ctx
				fmt.println("Connteced to lobby:", lobby.id)
			}
		)
	}
	// Received when someone accepts a request to spectate
	params.activity_events.on_activity_spectate = proc "system" (event_data: rawptr, secret: cstring) {
		context = state.ctx
		fmt.println("OnSpectate", secret)
	}
	// A join request has been received. Render the request on the UI.
	params.activity_events.on_activity_join_request = proc "system" (event_data: rawptr, user: ^discord.User) {
		context = state.ctx
		fmt.printfln("OnJoinRequest %v %s", user.id, user.username)
	}
	// An invite has been received. Consider rendering the user / activity on the UI.
	params.activity_events.on_activity_invite = proc "system" (event_data: rawptr, type: discord.ActivityActionType, user: ^discord.User, activity: ^discord.Activity) {
		context = state.ctx
		fmt.printfln("OnInvite %v %s %s", type, user.username, activity.name)

		state.activities->accept_invite(
			user.id, nil, 
			proc "system" (callback_data: rawptr, result: discord.Result) {
				context = state.ctx
				fmt.println("AcceptInvite", result)
			}
		)
	}
	// This is used to register the game in the registry such that Discord can find it.
	// This is only needed by games acquired from other platforms, like Steam.
	// state.activities->register_command()

	// The auth manager fires events as information about the current user changes.
	// This event will fire once on init.
	//
	// GetCurrentUser will error until this fires once.
	params.user_events.on_current_user_update = proc "system" (event_data: rawptr) {
		context = state.ctx
		require( state.users->get_current_user(&state.current_user) )
		fmt.printfln("%s\n%v", state.current_user.username, state.current_user.id)
	}
	// If you store Discord user ids in a central place like a leaderboard and want to render them.
	// The users manager can be used to fetch arbitrary Discord users. This only provides basic
	// information and does not automatically update like relationships.
	state.users->get_user(
		450795363658366976, nil, 
		proc "system" (callback_data: rawptr, result: discord.Result, user: ^discord.User) {
			context = state.ctx
			if result == .Ok {
				fmt.printfln("user fetched: %s", user.username)
				// Request users's avatar data.
                // This can only be done after a user is successfully fetched.
				fetch_avatar(user.id)

			} else {
				fmt.println("user fetch error:", result)
			}
		}
	)

	// It is important to assign this handle right away to get the initial relationships refresh.
	// This callback will only be fired when the whole list is initially loaded or was reset
	params.relationship_events.on_refresh = proc "system" (event_data: rawptr) {
		context = state.ctx
		// Filter a user's relationship list to be just friends
		state.relationships->filter (
			nil, proc "system" (filter_data: rawptr, relationship: ^discord.Relationship) -> bool {
				return relationship.type == .Friend
			}
		)

		count: i32
		require( state.relationships->count(&count) )

		// Loop over all friends a user has.
		fmt.println("relationships updated:", count)
		for i in 0..<min(count, 10) {
			// Get an individual relationship from the list
			r: discord.Relationship
			require( state.relationships->get_at(i, &r) )
			fmt.printfln("relationships: %v %s %v %s", r.type, r.user.username, r.presence.status, r.presence.activity.name)
			
			// Request relationship's avatar data.
			fetch_avatar(r.user.id)
		}
	}
	// All following relationship updates are delivered individually.
	// These are fired when a user gets a new friend, removes a friend, or a relationship's presence changes.
	params.relationship_events.on_relationship_update = proc "system" (event_data: rawptr, r: ^discord.Relationship) {
		context = state.ctx
		fmt.printfln("relationship updated %v %s %v %s", r.type, r.user.username, r.presence.status, r.presence.activity.name)
	}

	params.lobby_events.on_lobby_message = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64, data: [^]u8, data_length: u32) {
		context = state.ctx
		fmt.println("lobby message:", lobby_id, string(data[:data_length]))
	}
	params.lobby_events.on_network_message = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64, channel_id: u8, data: [^]u8, data_length: u32) {
		context = state.ctx
		fmt.println("network message:", lobby_id, user_id, channel_id, string(data[:data_length]));
	}
	params.lobby_events.on_speaking = proc "system" (event_data: rawptr, lobby_id: i64, user_id: i64, speaking: bool) {
		context = state.ctx
		fmt.println("lobby speaking:", lobby_id, user_id, speaking);
	}

	key: discord.MetadataKey
	value: discord.MetadataValue

	transaction: ^discord.LobbyTransaction
	require( state.lobbies->get_lobby_create_transaction(&transaction) )
	require( transaction->set_capacity(6) )
	require( transaction->set_type(.Public) )
	copy(key[:], "a"); copy(value[:], "123")
	require( transaction->set_metadata(key, value ))
	copy(value[:], "456")
	require( transaction->set_metadata(key, value) )
	copy(key[:], "b"); copy(value[:], "111")
	require( transaction->set_metadata(key, value) )
	copy(key[:], "c"); copy(value[:], "222")
	require( transaction->set_metadata(key, value) )


	state.lobbies->create_lobby(
		transaction, nil,
		proc "system" (callback_data: rawptr, result: discord.Result, lobby: ^discord.Lobby) {
			context = state.ctx
			if result != .Ok { return }

			// Check the lobby's configuration.
			fmt.printfln("lobby %v with capacity %v and secret %s", lobby.id, lobby.capacity, lobby.secret)

			// Check lobby metadata.
			keys := []string{"a","b","c"}
			for str in keys {
				key: discord.MetadataKey
				copy(key[:], str)
				value: discord.MetadataValue
				require( state.lobbies->get_lobby_metadata_value(lobby.id, key, &value) )
				fmt.printfln("%v = %s", str, value)
			}

			// Print all the members of the lobby.
			member_count: i32
			state.lobbies->member_count(lobby.id, &member_count)
			for i in 0..<member_count {
				user_id: discord.UserId
				require( state.lobbies->get_member_user_id(lobby.id, i, &user_id) )

				user: discord.User
				require( state.lobbies->get_member_user(lobby.id, user_id, &user) )

				fmt.printfln("lobby member: %s", user.username)
			}

			// Send everyone a message.
			lobby_message := "Hello from C#!"
			state.lobbies->send_lobby_message(
				lobby.id, raw_data(lobby_message), u32(len(lobby_message)), nil,
				proc "system" (callback_data: rawptr, result: discord.Result) {
					context = state.ctx
					fmt.println("sent message", result)
				}
			)

			// Update a member.
			member_transaction: ^discord.LobbyMemberTransaction
			require( state.lobbies->get_member_update_transaction(lobby.id, lobby.owner_id, &member_transaction) )

			key := discord.to_metadata_key("hello")
			value := discord.to_metadata_value("there")
			require( member_transaction->set_metadata(key, value) )
			state.lobbies->update_member(
				lobby.id, lobby.owner_id, member_transaction, lobby,
				proc "system" (callback_data: rawptr, result: discord.Result) {
					context = state.ctx
					lobby := (^discord.Lobby)(callback_data)
					key: discord.MetadataKey
					copy(key[:], "hello")
					value: discord.MetadataValue
					require( state.lobbies->get_member_metadata_value(lobby.id, lobby.owner_id, key, &value) )
					fmt.printfln("lobby member has been updated: %s", value)
				}
			)

			// Search lobbies.
			query: ^discord.LobbySearchQuery
			require( state.lobbies->get_search_query(&query) )
			discord.write_metadata_key(&key, "metadata.a")
			discord.write_metadata_value(&value, "455")
			// Filter by a metadata value.
			require( query->filter(key, .GreaterThan, .Number, value) )
			discord.write_metadata_value(&value, "0")
			require( query->sort(key, .Number, value) )
			// Only return 1 result max.
			require( query->limit(1) )
			state.lobbies->search(
				query, nil,
				proc "system" (callback_data: rawptr, result: discord.Result) {
					context = state.ctx
					count: i32
					state.lobbies->lobby_count(&count)
					fmt.println("search returned", count, "lobbies")
					if count == 1 {
						id: discord.LobbyId
						require( state.lobbies->get_lobby_id(0, &id) )
						lobby: discord.Lobby
						require( state.lobbies->get_lobby(id, &lobby) )
						fmt.printfln("first lobby secret: %s", lobby.secret)
					}
				}
			)

			// Connect to voice chat.
			state.lobbies->connect_voice(
				lobby.id, nil,
				proc "system" (callback_data: rawptr, result: discord.Result) {
					context = state.ctx
					fmt.println("Connected to voice chat!")
				}
			)

			// Setup networking.
			require( state.lobbies->connect_network(lobby.id) )
			require( state.lobbies->open_network_channel(lobby.id, 0, true) )

			// Update activity.
			update_activity(lobby)
		}
	)

	/*
	params.overlay_events.on_toggle = proc "system" (event_data: rawptr, locked: bool) {
		context = state.ctx
		fmt.println("Overlay Locked:", locked)
	}
	state.overlay->set_locked(false, nil, nil)
	*/

	contents := make([]byte, 20000)
	n := rand.read(contents)
	path: discord.Path
	require( state.storage->get_path(&path) )
	fmt.printfln("storage path: %s", path)
	state.storage->write_async(
		"foo", raw_data(&path), u32(len(path)), &path,
		proc "system" (callback_data: rawptr, result: discord.Result) {
			context = state.ctx
			path := (^discord.Path)(callback_data)

			file_count: i32
			state.storage->count(&file_count)

			for i in 0..<file_count {
				file_stat: discord.FileStat
				require( state.storage->stat_at(i, &file_stat) )
			}
		}
	)

	params.store_events.on_entitlement_create = proc "system" (event_data: rawptr, entitlement: ^discord.Entitlement) {
		context = state.ctx
		fmt.println("Entitlement Create:", entitlement.id)
	}

	/*
	state.store->start_purchase(
		487507201519255552, nil,
		proc "system" (callback_data: rawptr, result: discord.Result) {
			context = state.ctx
			if result == .Ok {
				fmt.println("Purchase Complete")
			} else {
				fmt.println("Purchase Canceled")
			}
		}
	)
	*/

	// Get all entitlements.
	state.store->fetch_entitlements(
		nil, proc "system" (callback_data: rawptr, result: discord.Result) {
			context = state.ctx
			count: i32
			state.store->count_entitlements(&count)

			for i in 0..<count {
				ent: discord.Entitlement
				require( state.store->get_entitlement_at(i, &ent) )
				fmt.printfln("entitlement: %v - %v %v", ent.id, ent.type, ent.sku_id)
			}
		}
	)

	// Get all SKUs.
	state.store->fetch_skus(
		nil, proc "system" (callback_data: rawptr, result: discord.Result) {
			context = state.ctx
			count: i32
			state.store->count_skus(&count)

			for i in 0..<count {
				sku: discord.Sku
				require( state.store->get_sku_at(i, &sku) )
				fmt.printfln("sku: %s - %v %v", sku.name, sku.price.amount, sku.price.currency)
			}
		}
	)
	
	@static interrupted: bool
	libc.signal(libc.SIGINT, proc "c" (i32) { interrupted = true })
	libc.signal(libc.SIGILL, proc "c" (i32) { interrupted = true })

	// Pump the event look to ensure all callbacks continue to get fired.
	for !interrupted {
		require( state.core->run_callbacks() )
		require( state.lobbies->flush_network() )
		time.sleep(time.Millisecond * 16)
	}
	fmt.println("Bye")
}

require :: proc(r: discord.Result, exp := #caller_expression(r), loc := #caller_location) { 
	fmt.assertf( r == .Ok, "Result Error: %v %v", r, exp, loc=loc)
}