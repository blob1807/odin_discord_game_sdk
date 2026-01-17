package discord_game_sdk

import "base:intrinsics"
import "base:runtime"
import "core:c"
import "core:log"

@require import "core:sys/windows"
@require import "vendor:directx/dxgi"


when #exists("./lib/x86_64/discord_game_sdk.dll.lib") {
	LIB_FOLDER :: "./lib"
} else when #exists("./discord_game_sdk/lib/x86_64/discord_game_sdk.dll.lib") {
	LIB_FOLDER :: "./discord_game_sdk/lib"
} else {
	LIB_FOLDER :: "" // Prevent `Undeclared name: LIB_FOLDER` error
	#panic("Couldn't find a `./discord_game_sdk/lib` or `./lib` folder")
}

when ODIN_OS == .Windows {
	when ODIN_ARCH == .amd64 {
		LIB_PATH :: LIB_FOLDER + "/x86_64/discord_game_sdk.dll.lib"
	} else when ODIN_ARCH == .i386 {
		LIB_PATH :: LIB_FOLDER + "/x86/discord_game_sdk.dll.lib"
	} else {
		#panic("Windows: The target architecture is unsupported; " + ODIN_ARCH_STRING)
	}
	
} else when ODIN_OS == .Linux {
	when ODIN_ARCH == .amd64 {
		LIB_PATH :: LIB_FOLDER + "/x86_64/discord_game_sdk.so"
	} else {
		#panic("Linux: The target architecture is unsupported; " + ODIN_ARCH_STRING)
	}

} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .amd64 {
		LIB_PATH :: LIB_FOLDER + "/x86_64/discord_game_sdk.dylib"
	} else when ODIN_ARCH == .arm64 {
		LIB_PATH :: LIB_FOLDER + "/aarch64/discord_game_sdk.dylib"
	} else {
		#panic("Darwin: The target architecture is unsupported; " + ODIN_ARCH_STRING)
	}

} else {
	#panic("The target OS is unsupported; " + ODIN_OS_STRING)
}

foreign import sdk_lib { LIB_PATH }

SDK_VERSION :: "3.2.1"

VERSION                      :: 3
APPLICATION_MANAGER_VERSION  :: 1
USER_MANAGER_VERSION         :: 1
IMAGE_MANAGER_VERSION        :: 1
ACTIVITY_MANAGER_VERSION     :: 1
RELATIONSHIP_MANAGER_VERSION :: 1
LOBBY_MANAGER_VERSION        :: 1
NETWORK_MANAGER_VERSION      :: 1
OVERLAY_MANAGER_VERSION      :: 2
STORAGE_MANAGER_VERSION      :: 1
STORE_MANAGER_VERSION        :: 1
VOICE_MANAGER_VERSION        :: 1
ACHIEVEMENT_MANAGER_VERSION  :: 1

DEFAULT_CREATE_PARAMS :: CreateParams {
	application_version  = APPLICATION_MANAGER_VERSION,
	user_version         = USER_MANAGER_VERSION,
	image_version        = IMAGE_MANAGER_VERSION,
	activity_version     = ACTIVITY_MANAGER_VERSION,
	relationship_version = RELATIONSHIP_MANAGER_VERSION,
	lobby_version        = LOBBY_MANAGER_VERSION,
	network_version      = NETWORK_MANAGER_VERSION,
	overlay_version      = OVERLAY_MANAGER_VERSION,
	storage_version      = STORAGE_MANAGER_VERSION,
	store_version        = STORE_MANAGER_VERSION,
	voice_version        = VOICE_MANAGER_VERSION,
	achievement_version  = ACHIEVEMENT_MANAGER_VERSION,
}

Result :: enum c.int {
	Ok                              =  0,
	ServiceUnavailable              =  1,
	InvalidVersion                  =  2,
	LockFailed                      =  3,
	InternalError                   =  4,
	InvalidPayload                  =  5,
	InvalidCommand                  =  6,
	InvalidPermissions              =  7,
	NotFetched                      =  8,
	NotFound                        =  9,
	Conflict                        = 10,
	InvalidSecret                   = 11,
	InvalidJoinSecret               = 12,
	NoEligibleActivity              = 13,
	InvalidInvite                   = 14,
	NotAuthenticated                = 15,
	InvalidAccessToken              = 16,
	ApplicationMismatch             = 17,
	InvalidDataUrl                  = 18,
	InvalidBase64                   = 19,
	NotFiltered                     = 20,
	LobbyFull                       = 21,
	InvalidLobbySecret              = 22,
	InvalidFilename                 = 23,
	InvalidFileSize                 = 24,
	InvalidEntitlement              = 25,
	NotInstalled                    = 26,
	NotRunning                      = 27,
	InsufficientBuffer              = 28,
	PurchaseCanceled                = 29,
	InvalidGuild                    = 30,
	InvalidEvent                    = 31,
	InvalidChannel                  = 32,
	InvalidOrigin                   = 33,
	RateLimited                     = 34,
	OAuth2Error                     = 35,
	SelectChannelTimeout            = 36,
	GetGuildTimeout                 = 37,
	SelectVoiceForceRequired        = 38,
	CaptureShortcutAlreadyListening = 39,
	UnauthorizedForAchievement      = 40,
	InvalidGiftCode                 = 41,
	PurchaseError                   = 42,
	TransactionAborted              = 43,
	DrawingInitFailed               = 44,
}

CreateFlags  :: enum c.uint64_t {
	Default          = 0,
	NoRequireDiscord = 1,
}

LogLevel :: enum c.int {
	Error = 1,
	Warn,
	Info,
	Debug,
}

UserFlag :: enum c.int {
	Partner         =   2,
	HypeSquadEvents =   4,
	HypeSquadHouse1 =  64,
	HypeSquadHouse2 = 128,
	HypeSquadHouse3 = 256,
}

PremiumType :: enum c.int {
	None  = 0,
	Tier1 = 1,
	Tier2 = 2,
}

ImageType :: enum c.int {
	User,
}

ActivityPartyPrivacy :: enum c.int {
	Private = 0,
	Public  = 1,
}

ActivityType :: enum c.int {
	Playing,
	Streaming,
	Listening,
	Watching,
}

ActivityActionType :: enum c.int {
	Join = 1,
	Spectate,
}

ActivitySupportedPlatformFlags :: bit_set[ActivitySupportedPlatformFlag; c.uint32_t]
ActivitySupportedPlatformFlag  :: enum c.uint32_t {
	Desktop = 1,
	Android = 2,
	iOS     = 3,
}

ActivityJoinRequestReply :: enum c.int {
	No,
	Yes,
	Ignore,
}

Status :: enum c.int {
	Offline      = 0,
	Online       = 1,
	Idle         = 2,
	DoNotDisturb = 3,
}

RelationshipType :: enum c.int {
	None,
	Friend,
	Blocked,
	PendingIncoming,
	PendingOutgoing,
	Implicit,
}

LobbyType :: enum c.int {
	Private = 1,
	Public,
}

LobbySearchComparison :: enum c.int {
	LessThanOrEqual = -2,
	LessThan,
	Equal,
	GreaterThan,
	GreaterThanOrEqual,
	NotEqual,
}

LobbySearchCast :: enum c.int {
	String = 1,
	Number,
}

LobbySearchDistance :: enum c.int {
	Local,
	Default,
	Extended,
	Global,
}

KeyVariant :: enum c.int {
	Normal,
	Right,
	Left,
}

MouseButton :: enum c.int {
	Left,
	Middle,
	Right,
}

EntitlementType :: enum c.int {
	Purchase = 1,
	PremiumSubscription,
	DeveloperGift,
	TestModePurchase,
	FreePurchase,
	UserGift,
	PremiumPurchase,
}

SkuType :: enum c.int {
	Application = 1,
	DLC,
	Consumable,
	Bundle,
}

InputModeType :: enum c.int {
	VoiceActivity = 0,
	PushToTalk,
}

ClientId         :: c.int64_t
Version          :: c.int32_t
Snowflake        :: c.int64_t
Timestamp        :: c.int64_t
UserId           :: Snowflake
Locale           :: [128]c.char
Branch           :: [4096]c.char
LobbyId          :: Snowflake
LobbySecret      :: [128]c.char
MetadataKey      :: [256]c.char
MetadataValue    :: [4096]c.char
NetworkPeerId    :: c.uint64_t
NetworkChannelId :: c.uint8_t

when ODIN_OS == .Windows {
	IDXGISwapChain :: dxgi.ISwapChain
	MSG :: windows.MSG
} else {
	IDXGISwapChain :: struct {}
	MSG :: struct {}
}

Path     :: [4096]c.char
DateTime :: [64]c.char

User :: struct {
	id:            UserId,
	username:      [256]c.char `fmt:"s`,
	discriminator: [8]c.char   `fmt:"s`,
	avatar:        [128]c.char `fmt:"s`,
	bot:           bool,
}

OAuth2Token :: struct {
	access_token: [128]c.char  `fmt:"s`,
	scopes:       [1024]c.char `fmt:"s`,
	expires:      Timestamp,
}

ImageHandle :: struct {
	type: ImageType,
	id:   c.int64_t,
	size: c.int32_t,
}

ImageDimensions :: struct {
	width:  c.uint32_t,
	height: c.uint32_t,
}

ActivityTimestamps :: struct {
	start: Timestamp,
	end:   Timestamp,
}

ActivityAssets :: struct {
	large_image: [128]c.char `fmt:"s`,
	large_text:  [128]c.char `fmt:"s`,
	small_image: [128]c.char `fmt:"s`,
	small_text:  [128]c.char `fmt:"s`,
}

PartySize :: struct {
	current_size: c.int32_t,
	max_size:     c.int32_t,
}

ActivityParty :: struct {
	id:      [128]c.char `fmt:"s`,
	size:    PartySize,
	privacy: ActivityPartyPrivacy,
}

ActivitySecrets :: struct {
	match:    [128]c.char `fmt:"s`,
	join:     [128]c.char `fmt:"s`,
	spectate: [128]c.char `fmt:"s`,
}

Activity :: struct {
	type:                ActivityType,
	application_id:      c.int64_t,
	name:                [128]c.char `fmt:"s`,
	state:               [128]c.char `fmt:"s`,
	details:             [128]c.char `fmt:"s`,
	timestamps:          ActivityTimestamps,
	assets:              ActivityAssets,
	party:               ActivityParty,
	secrets:             ActivitySecrets,
	instance:            c.bool,
	supported_platforms: ActivitySupportedPlatformFlags,
}

Presence :: struct {
	status:   Status,
	activity: Activity,
}

Relationship :: struct {
	type:     RelationshipType,
	user:     User,
	presence: Presence,
}

Lobby :: struct {
	id:       LobbyId,
	type:     LobbyType,
	owner_id: UserId,
	secret:   LobbySecret,
	capacity: c.uint32_t,
	locked:   bool,
}

ImeUnderline :: struct {
	from:             c.int32_t,
	to:               c.int32_t,
	color:            c.int32_t,
	background_color: c.int32_t,
	thick:            bool,
}

Rect :: struct {
	left:   c.int32_t,
	top:    c.int32_t,
	right:  c.int32_t,
	bottom: c.int32_t,
}

FileStat :: struct {
	filename:      [260]c.char `fmt:"s`,
	size:          c.uint64_t,
	last_modified: c.uint64_t,
}

Entitlement :: struct {
	id:     Snowflake,
	type:   EntitlementType,
	sku_id: Snowflake,
}

SkuPrice :: struct {
	amount:   c.uint32_t,
	currency: [16]c.char,
}

Sku :: struct {
	id:    Snowflake,
	type:  SkuType,
	name:  [256]c.char `fmt:"s`,
	price: SkuPrice,
}

InputMode :: struct {
	type:     InputModeType,
	shortcut: [256]c.char `fmt:"s`,
}

UserAchievement :: struct {
	user_id:          Snowflake,
	achievement_id:   Snowflake,
	percent_complete: c.uint8_t,
	unlocked_at:      DateTime,
}

LobbyTransaction :: struct {
	set_type:        proc "system" (lobby_transaction: ^LobbyTransaction, type: LobbyType) -> Result,
	set_owner:       proc "system" (lobby_transaction: ^LobbyTransaction, owner_id: UserId) -> Result,
	set_capacity:    proc "system" (lobby_transaction: ^LobbyTransaction, capacity: c.uint32_t) -> Result,
	set_metadata:    proc "system" (lobby_transaction: ^LobbyTransaction, key: MetadataKey, value: MetadataValue) -> Result,
	delete_metadata: proc "system" (lobby_transaction: ^LobbyTransaction, key: MetadataKey) -> Result,
	set_locked:      proc "system" (lobby_transaction: ^LobbyTransaction, locked: bool) -> Result,
}

LobbyMemberTransaction :: struct {
	set_metadata:    proc "system" (lobby_member_transaction: ^LobbyMemberTransaction, key: MetadataKey, value: MetadataValue) -> Result,
	delete_metadata: proc "system" (lobby_member_transaction: ^LobbyMemberTransaction, key: MetadataKey) -> Result,
}

LobbySearchQuery :: struct {
	filter:   proc "system" (lobby_search_query: ^LobbySearchQuery, key: MetadataKey, comparison: LobbySearchComparison, cast_: LobbySearchCast, value: MetadataValue) -> Result,
	sort:     proc "system" (lobby_search_query: ^LobbySearchQuery, key: MetadataKey, cast_: LobbySearchCast, value: MetadataValue) -> Result,
	limit:    proc "system" (lobby_search_query: ^LobbySearchQuery, limit: c.uint32_t) -> Result,
	distance: proc "system" (lobby_search_query: ^LobbySearchQuery, distance: LobbySearchDistance) -> Result,
}

ApplicationEvents :: rawptr

ApplicationManager :: struct { 
	validate_or_exit:   proc "system" (manager: ^ApplicationManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	get_current_locale: proc "system" (manager: ^ApplicationManager, locale: ^Locale),
	get_current_branch: proc "system" (manager: ^ApplicationManager, branch: ^Branch),
	get_oauth2_token:   proc "system" (manager: ^ApplicationManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, oauth2_token: ^OAuth2Token)),
	get_ticket:         proc "system" (manager: ^ApplicationManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, data: cstring)),
}

UserEvents :: struct {
	on_current_user_update: proc "system" (event_data: rawptr),
}

UserManager :: struct {
	get_current_user:              proc "system" (manager: ^UserManager, current_user: ^User) -> Result,
	get_user:                      proc "system" (manager: ^UserManager, user_id: UserId, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, user: ^User)),
	get_current_user_premium_type: proc "system" (manager: ^UserManager, premium_type: ^PremiumType) -> Result,
	current_user_has_flag:         proc "system" (manager: ^UserManager, flag: UserFlag, has_flag: ^bool) -> Result,
}

ImageEvents :: rawptr

ImageManager :: struct {
	fetch:          proc "system" (manager: ^ImageManager, handle: ImageHandle, refresh: bool, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, handle_result: ImageHandle)),
	get_dimensions: proc "system" (manager: ^ImageManager, handle: ImageHandle, dimensions: ^ImageDimensions) -> Result,
	get_data:       proc "system" (manager: ^ImageManager, handle: ImageHandle, data: [^]c.uint8_t, data_length: c.uint32_t) -> Result,
}

ActivityEvents :: struct {
	on_activity_join:         proc "system" (event_data: rawptr, secret: cstring),
	on_activity_spectate:     proc "system" (event_data: rawptr, secret: cstring),
	on_activity_join_request: proc "system" (event_data: rawptr, user: ^User),
	on_activity_invite:       proc "system" (event_data: rawptr, type: ActivityActionType, user: ^User, activity: ^Activity),
}

ActivityManager :: struct {
	register_command:   proc "system" (manager: ^ActivityManager, command: cstring) -> Result,
	register_steam:     proc "system" (manager: ^ActivityManager, steam_id: c.uint32_t) -> Result,
	update_activity:    proc "system" (manager: ^ActivityManager, activity: ^Activity, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	clear_activity:     proc "system" (manager: ^ActivityManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	send_request_reply: proc "system" (manager: ^ActivityManager, user_id: UserId, reply: ActivityJoinRequestReply, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	send_invite:        proc "system" (manager: ^ActivityManager, user_id: UserId, type: ActivityActionType, content: cstring, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	accept_invite:      proc "system" (manager: ^ActivityManager, user_id: UserId, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
}

RelationshipEvents :: struct {
	on_refresh:             proc "system" (event_data: rawptr),
	on_relationship_update: proc "system" (event_data: rawptr, relationship: ^Relationship),
}

RelationshipManager :: struct {
	filter: proc "system" (manager: ^RelationshipManager, filter_data: rawptr, filter: proc "system" (filter_data: rawptr, relationship: ^Relationship) -> bool),
	count:  proc "system" (manager: ^RelationshipManager, count: ^c.int32_t) -> Result,
	get:    proc "system" (manager: ^RelationshipManager, user_id: UserId, relationship: ^Relationship) -> Result,
	get_at: proc "system" (manager: ^RelationshipManager, index: c.int32_t, relationship: ^Relationship) -> Result,
}

LobbyEvents :: struct {
	on_lobby_update:      proc "system" (event_data: rawptr, lobby_id: c.int64_t),
	on_lobby_delete:      proc "system" (event_data: rawptr, lobby_id: c.int64_t, reason:  c.uint32_t),
	on_member_connect:    proc "system" (event_data: rawptr, lobby_id: c.int64_t, user_id: c.int64_t),
	on_member_update:     proc "system" (event_data: rawptr, lobby_id: c.int64_t, user_id: c.int64_t),
	on_member_disconnect: proc "system" (event_data: rawptr, lobby_id: c.int64_t, user_id: c.int64_t),
	on_lobby_message:     proc "system" (event_data: rawptr, lobby_id: c.int64_t, user_id: c.int64_t, data: [^]c.uint8_t, data_length: c.uint32_t),
	on_speaking:          proc "system" (event_data: rawptr, lobby_id: c.int64_t, user_id: c.int64_t, speaking: bool),
	on_network_message:   proc "system" (event_data: rawptr, lobby_id: c.int64_t, user_id: c.int64_t, channel_id: c.uint8_t, data: [^]c.uint8_t, data_length: c.uint32_t),
}

LobbyManager :: struct {
	get_lobby_create_transaction:       proc "system" (manager: ^LobbyManager, transaction: ^^LobbyTransaction) -> Result,
	get_lobby_update_transaction:       proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, transaction: ^^LobbyTransaction) -> Result,
	get_member_update_transaction:      proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, transaction: ^^LobbyMemberTransaction) -> Result,
	create_lobby:                       proc "system" (manager: ^LobbyManager, transaction: ^LobbyTransaction, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, lobby: ^Lobby)),
	update_lobby:                       proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, transaction: ^LobbyTransaction, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	delete_lobby:                       proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	connect_lobby:                      proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, secret: LobbySecret, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, lobby: ^Lobby)),
	connect_lobby_with_activity_secret: proc "system" (manager: ^LobbyManager, activity_secret: LobbySecret, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, lobby: ^Lobby)),
	disconnect_lobby:                   proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	get_lobby:                          proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, lobby: ^Lobby) -> Result,
	get_lobby_activity_secret:          proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, secret: ^LobbySecret) -> Result,
	get_lobby_metadata_value:           proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, key: MetadataKey, value: ^MetadataValue) -> Result,
	get_lobby_metadata_key:             proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, index:  c.int32_t, key: ^MetadataKey) -> Result,
	lobby_metadata_count:               proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, count: ^c.int32_t) -> Result,
	member_count:                       proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, count: ^c.int32_t) -> Result,
	get_member_user_id:                 proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, index:  c.int32_t, user_id: ^UserId) -> Result,
	get_member_user:                    proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, user: ^User) -> Result,
	get_member_metadata_value:          proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, key: MetadataKey, value: ^MetadataValue) -> Result,
	get_member_metadata_key:            proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, index:  c.int32_t, key: ^MetadataKey) -> Result,
	member_metadata_count:              proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, count: ^c.int32_t) -> Result,
	update_member:                      proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, transaction: ^LobbyMemberTransaction, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	send_lobby_message:                 proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, data: [^]c.uint8_t, data_length: c.uint32_t, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	get_search_query:                   proc "system" (manager: ^LobbyManager, query: ^^LobbySearchQuery) -> Result,
	search:                             proc "system" (manager: ^LobbyManager, query:  ^LobbySearchQuery, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	lobby_count:                        proc "system" (manager: ^LobbyManager, count: ^c.int32_t),
	get_lobby_id:                       proc "system" (manager: ^LobbyManager, index:  c.int32_t, lobby_id: ^LobbyId) -> Result,
	connect_voice:                      proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	disconnect_voice:                   proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	connect_network:                    proc "system" (manager: ^LobbyManager, lobby_id: LobbyId) -> Result,
	disconnect_network:                 proc "system" (manager: ^LobbyManager, lobby_id: LobbyId) -> Result,
	flush_network:                      proc "system" (manager: ^LobbyManager) -> Result,
	open_network_channel:               proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, channel_id: c.uint8_t, reliable: bool) -> Result,
	send_network_message:               proc "system" (manager: ^LobbyManager, lobby_id: LobbyId, user_id: UserId, channel_id: c.uint8_t, data: [^]c.uint8_t, data_length: c.uint32_t) -> Result,
}

NetworkEvents :: struct {
	on_message:      proc "system" (event_data: rawptr, peer_id: NetworkPeerId, channel_id: NetworkChannelId, data: [^]c.uint8_t,  data_length: c.uint32_t),
	on_route_update: proc "system" (event_data: rawptr, route_data: cstring),
}

NetworkManager :: struct {
	/**
	 * Get the local peer ID for this process.
	 */
	get_peer_id:   proc "system" (manager: ^NetworkManager, peer_id: ^NetworkPeerId),
	/**
	 * Send pending network messages.
	 */
	flush:         proc "system" (manager: ^NetworkManager) -> Result,
	/**
	 * Open a connection to a remote peer.
	 */
	open_peer:     proc "system" (manager: ^NetworkManager, peer_id: NetworkPeerId, route_data: cstring) -> Result,
	/**
	 * Update the route data for a connected peer.
	 */
	update_peer:   proc "system" (manager: ^NetworkManager, peer_id: NetworkPeerId, route_data: cstring) -> Result,
	/**
	 * Close the connection to a remote peer.
	 */
	close_peer:    proc "system" (manager: ^NetworkManager, peer_id: NetworkPeerId) -> Result,
	/**
	 * Open a message channel to a connected peer.
	 */
	open_channel:  proc "system" (manager: ^NetworkManager, peer_id: NetworkPeerId, channel_id: NetworkChannelId, reliable: bool) -> Result,
	/**
	 * Close a message channel to a connected peer.
	 */
	close_channel: proc "system" (manager: ^NetworkManager, peer_id: NetworkPeerId, channel_id: NetworkChannelId) -> Result,
	/**
	 * Send a message to a connected peer over an opened message channel.
	 */
	send_message:  proc "system" (manager: ^NetworkManager, peer_id: NetworkPeerId, channel_id: NetworkChannelId, data: [^]c.uint8_t, data_length: c.uint32_t) -> Result,
}

OverlayEvents :: struct {
	on_toggle: proc "system" (event_data: rawptr, locked: bool),
}

OverlayManager :: struct {
	is_enabled:                         proc "system" (manager: ^OverlayManager, enabled: ^bool),
	is_locked:                          proc "system" (manager: ^OverlayManager, locked:  ^bool),
	set_locked:                         proc "system" (manager: ^OverlayManager, locked: bool, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	open_activity_invite:               proc "system" (manager: ^OverlayManager, type: ActivityActionType, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	open_guild_invite:                  proc "system" (manager: ^OverlayManager, code: cstring, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	open_voice_settings:                proc "system" (manager: ^OverlayManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	init_drawing_dxgi:                  proc "system" (manager: ^OverlayManager, swapchain: ^IDXGISwapChain, use_message_forwarding: bool) -> Result,
	on_present:                         proc "system" (manager: ^OverlayManager),
	forward_message:                    proc "system" (manager: ^OverlayManager, message: ^MSG),
	key_event:                          proc "system" (manager: ^OverlayManager, down: bool, key_code: cstring, variant: KeyVariant),
	char_event:                         proc "system" (manager: ^OverlayManager, character: cstring),
	mouse_button_event:                 proc "system" (manager: ^OverlayManager, down: c.uint8_t, click_count: c.int32_t, which: MouseButton, x: c.int32_t, y: c.int32_t),
	mouse_motion_event:                 proc "system" (manager: ^OverlayManager, x: c.int32_t, y: c.int32_t),
	ime_commit_text:                    proc "system" (manager: ^OverlayManager, text: cstring),
	ime_set_composition:                proc "system" (manager: ^OverlayManager, text: cstring, underlines: ^ImeUnderline, underlines_length: c.uint32_t, from: c.int32_t, to: c.int32_t),
	ime_cancel_composition:             proc "system" (manager: ^OverlayManager),
	set_ime_composition_range_callback: proc "system" (manager: ^OverlayManager, on_ime_composition_range_changed_data: rawptr, on_ime_composition_range_changed: proc "system" (on_ime_composition_range_changed_data: rawptr, from: c.int32_t, to: c.int32_t, bounds: ^Rect, bounds_length: c.uint32_t)),
	set_ime_selection_bounds_callback:  proc "system" (manager: ^OverlayManager, on_ime_selection_bounds_changed_data:  rawptr, on_ime_selection_bounds_changed:  proc "system" (on_ime_selection_bounds_changed_data:  rawptr, anchor: Rect, focus: Rect, is_anchor_first: bool)),
	is_point_inside_click_zone:         proc "system" (manager: ^OverlayManager, x:c.int32_t, y: c.int32_t) -> bool,
}

StorageEvents :: rawptr

StorageManager :: struct {
	read:               proc "system" (manager: ^StorageManager, name: cstring, data: [^]c.uint8_t, data_length: c.uint32_t, read: ^c.uint32_t) -> Result,
	read_async:         proc "system" (manager: ^StorageManager, name: cstring, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, data: [^]c.uint8_t, data_length: c.uint32_t)),
	read_async_partial: proc "system" (manager: ^StorageManager, name: cstring, offset: c.uint64_t, length: c.uint64_t, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result, data: [^]c.uint8_t, data_length: c.uint32_t)),
	write:              proc "system" (manager: ^StorageManager, name: cstring, data: [^]c.uint8_t, data_length: c.uint32_t) -> Result,
	write_async:        proc "system" (manager: ^StorageManager, name: cstring, data: [^]c.uint8_t, data_length: c.uint32_t, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	delete:             proc "system" (manager: ^StorageManager, name: cstring) -> Result,
	exists:             proc "system" (manager: ^StorageManager, name: cstring, exists: ^bool) -> Result,
	count:              proc "system" (manager: ^StorageManager, count: ^c.int32_t),
	stat:               proc "system" (manager: ^StorageManager, name: cstring,    stat: ^FileStat) -> Result,
	stat_at:            proc "system" (manager: ^StorageManager, index: c.int32_t, stat: ^FileStat) -> Result,
	get_path:           proc "system" (manager: ^StorageManager, path: ^Path) -> Result,
}

StoreEvents :: struct {
	on_entitlement_create: proc "system" (event_data: rawptr, entitlement: ^Entitlement),
	on_entitlement_delete: proc "system" (event_data: rawptr, entitlement: ^Entitlement),
}

StoreManager :: struct {
	fetch_skus:          proc "system" (manager: ^StoreManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	count_skus:          proc "system" (manager: ^StoreManager, count: ^c.int32_t),
	get_sku:             proc "system" (manager: ^StoreManager, sku_id: Snowflake, sku: ^Sku) -> Result,
	get_sku_at:          proc "system" (manager: ^StoreManager, index:  c.int32_t, sku: ^Sku) -> Result,
	fetch_entitlements:  proc "system" (manager: ^StoreManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	count_entitlements:  proc "system" (manager: ^StoreManager, count: ^c.int32_t),
	get_entitlement:     proc "system" (manager: ^StoreManager, entitlement_id: Snowflake, entitlement: ^Entitlement) -> Result,
	get_entitlement_at:  proc "system" (manager: ^StoreManager, index:  c.int32_t, entitlement: ^Entitlement) -> Result,
	has_sku_entitlement: proc "system" (manager: ^StoreManager, sku_id: Snowflake, has_entitlement: ^bool) -> Result,
	start_purchase:      proc "system" (manager: ^StoreManager, sku_id: Snowflake, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
}

VoiceEvents :: struct {
	on_settings_update: proc "system" (event_data: rawptr),
}

VoiceManager :: struct {
	get_input_mode:   proc "system" (manager: ^VoiceManager, input_mode: ^InputMode) -> Result,
	set_input_mode:   proc "system" (manager: ^VoiceManager, input_mode:  InputMode, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	is_self_mute:     proc "system" (manager: ^VoiceManager, mute: ^bool) -> Result,
	set_self_mute:    proc "system" (manager: ^VoiceManager, mute:  bool) -> Result,
	is_self_deaf:     proc "system" (manager: ^VoiceManager, deaf: ^bool) -> Result,
	set_self_deaf:    proc "system" (manager: ^VoiceManager, deaf:  bool) -> Result,
	is_local_mute:    proc "system" (manager: ^VoiceManager, user_id: Snowflake, mute: ^bool) -> Result,
	set_local_mute:   proc "system" (manager: ^VoiceManager, user_id: Snowflake, mute:  bool) -> Result,
	get_local_volume: proc "system" (manager: ^VoiceManager, user_id: Snowflake, volume: ^c.uint8_t) -> Result,
	set_local_volume: proc "system" (manager: ^VoiceManager, user_id: Snowflake, volume:  c.uint8_t) -> Result,
}

AchievementEvents :: struct {
	on_user_achievement_update: proc "system" (event_data: rawptr, user_achievement: ^UserAchievement),
}

AchievementManager :: struct {
	set_user_achievement:    proc "system" (manager: ^AchievementManager, achievement_id: Snowflake, percent_complete: c.uint8_t, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	fetch_user_achievements: proc "system" (manager: ^AchievementManager, callback_data: rawptr, callback: proc "system" (callback_data: rawptr, result: Result)),
	count_user_achievements: proc "system" (manager: ^AchievementManager, count: ^c.int32_t),
	get_user_achievement:    proc "system" (manager: ^AchievementManager, user_achievement_id: Snowflake, user_achievement: ^UserAchievement) -> Result,
	get_user_achievement_at: proc "system" (manager: ^AchievementManager, index: c.int32_t, user_achievement: ^UserAchievement) -> Result,
}

CoreEvents :: rawptr

Core :: struct {
	destroy:                  proc "system" (core: ^Core),
	run_callbacks:            proc "system" (core: ^Core) ->  Result,
	set_log_hook:             proc "system" (core: ^Core, min_level: LogLevel, hook_data: rawptr, hook: proc "system" (hook_data: rawptr, level: LogLevel, message: cstring)),
	get_application_manager:  proc "system" (core: ^Core) -> ^ApplicationManager,
	get_user_manager:         proc "system" (core: ^Core) -> ^UserManager,
	get_image_manager:        proc "system" (core: ^Core) -> ^ImageManager,
	get_activity_manager:     proc "system" (core: ^Core) -> ^ActivityManager,
	get_relationship_manager: proc "system" (core: ^Core) -> ^RelationshipManager,
	get_lobby_manager:        proc "system" (core: ^Core) -> ^LobbyManager,
	get_network_manager:      proc "system" (core: ^Core) -> ^NetworkManager,
	get_overlay_manager:      proc "system" (core: ^Core) -> ^OverlayManager,
	get_storage_manager:      proc "system" (core: ^Core) -> ^StorageManager,
	get_store_manager:        proc "system" (core: ^Core) -> ^StoreManager,
	get_voice_manager:        proc "system" (core: ^Core) -> ^VoiceManager,
	get_achievement_manager:  proc "system" (core: ^Core) -> ^AchievementManager,
}

CreateParams :: struct {
	client_id:             ClientId,
	flags:                 CreateFlags,
	events:               ^CoreEvents,
	event_data:            rawptr,
	application_events:   ^ApplicationEvents,
	application_version:   Version,
	user_events:          ^UserEvents,
	user_version:          Version,
	image_events:         ^ImageEvents,
	image_version:         Version,
	activity_events:      ^ActivityEvents,
	activity_version:      Version,
	relationship_events:  ^RelationshipEvents,
	relationship_version:  Version,
	lobby_events:         ^LobbyEvents,
	lobby_version:         Version,
	network_events:       ^NetworkEvents,
	network_version:       Version,
	overlay_events:       ^OverlayEvents,
	overlay_version:       Version,
	storage_events:       ^StorageEvents,
	storage_version:       Version,
	store_events:         ^StoreEvents,
	store_version:         Version,
	voice_events:         ^VoiceEvents,
	voice_version:         Version,
	achievement_events:   ^AchievementEvents,
	achievement_version:   Version,
}


CreateParamsSetDefault :: proc "contextless" (params: ^CreateParams) {
	intrinsics.mem_zero(params, size_of(CreateParams))
	params^ = DEFAULT_CREATE_PARAMS
}

@(link_prefix="Discord", default_calling_convention="system")
foreign sdk_lib {
	Create :: proc(version: Version, params: ^CreateParams, result: ^^Core) -> Result ---
}




/* =============================== Helpers =============================== */


// Total size of the data `CreateParams.*_events` pointers point to.  
// Useful for putting them all in one arena.
PARAMA_EVENTS_SIZE :: size_of(CoreEvents)     + size_of(ApplicationEvents) + \
					  size_of(UserEvents)     + size_of(ImageEvents) + \
					  size_of(ActivityEvents) + size_of(RelationshipEvents) + \
					  size_of(LobbyEvents)    + size_of(NetworkEvents) + \
					  size_of(OverlayEvents)  + size_of(StorageEvents) + \
					  size_of(StoreEvents)    + size_of(VoiceEvents) + \
					  size_of(AchievementEvents)

// Allocates & Initializes an new `CreateParams` & allocates each `CreateParams.*_events`
new_params :: proc(client_id: ClientId, flags: CreateFlags, event_data: rawptr, alloc := context.allocator) -> (params: ^CreateParams) {
	params = new(CreateParams, alloc)
	init_params(params, client_id, flags, event_data, alloc)
	return
}

// Initializes an new `CreateParams` & allocates each `CreateParams.*_events`
init_params :: proc(p: ^CreateParams, id: ClientId, flags: CreateFlags, event_data: rawptr, events_alloc := context.allocator) {
	context.allocator = events_alloc
	CreateParamsSetDefault(p)

	p.client_id  = id
	p.flags      = flags
	p.event_data = event_data

	p.events              = new(CoreEvents)
	p.application_events  = new(ApplicationEvents)
	p.user_events         = new(UserEvents)
	p.image_events        = new(ImageEvents)
	p.activity_events     = new(ActivityEvents)
	p.relationship_events = new(RelationshipEvents)
	p.lobby_events        = new(LobbyEvents)
	p.network_events      = new(NetworkEvents)
	p.overlay_events      = new(OverlayEvents)
	p.storage_events      = new(StorageEvents)
	p.store_events        = new(StoreEvents)
	p.voice_events        = new(VoiceEvents)
	p.achievement_events  = new(AchievementEvents)
}


// Destroys a `CreateParams` & its `CreateParams.*_events`.  
// Setting all freed pointers to `nil`.
destroy_params :: proc(p: ^^CreateParams, alloc := context.allocator) {
	free_params_events(p^, alloc)
	free_params(p^, alloc)
	p^ = nil
}


// Frees a `CreateParams`.
free_params :: proc(p: ^CreateParams, alloc := context.allocator) {
	free(p, alloc)
}

// Frees a `CreateParams`' `CreateParams.*_events`.  
// Setting all freed pointers to `nil`.
free_params_events :: proc(p: ^CreateParams, events_alloc := context.allocator) {
	context.allocator = events_alloc

	free(p.events)
	free(p.application_events )
	free(p.user_events)
	free(p.image_events)
	free(p.activity_events)
	free(p.relationship_events)
	free(p.lobby_events)
	free(p.network_events)
	free(p.overlay_events)
	free(p.storage_events)
	free(p.store_events)
	free(p.voice_events)
	free(p.achievement_events)

	p.events              = nil
	p.application_events  = nil
	p.user_events         = nil
	p.image_events        = nil
	p.activity_events     = nil
	p.relationship_events = nil
	p.lobby_events        = nil
	p.network_events      = nil
	p.overlay_events      = nil
	p.storage_events      = nil
	p.store_events        = nil
	p.voice_events        = nil
	p.achievement_events  = nil
}


// `hook_data` is assumed to point to a `runtime.Context`.  
discord_logger :: proc "system" (hook_data: rawptr, level: LogLevel, message: cstring) {
	context = (^runtime.Context)(hook_data)^
	
	switch level {
	case .Debug: log.debug(message)
	case .Info:  log.info(message)
	case .Warn:  log.warn(message)
	case .Error: log.error(message)
	}

}


get_image_data :: proc(img_man: ^ImageManager, handle: ImageHandle, alloc := context.allocator) -> (res: []byte, dims: ImageDimensions) {
	img_man->get_dimensions(handle, &dims)

	res = make([]byte, dims.width * dims.height * 4, alloc)
	if res == nil { return }
	img_man->get_data(handle, raw_data(res), u32(len(res)))

	return
}


Managers :: struct {
	applications:  ^ApplicationManager,
	users:         ^UserManager,
	images:        ^ImageManager,
	activities:    ^ActivityManager,
	relationships: ^RelationshipManager,
	lobbies:       ^LobbyManager,
	network:       ^NetworkManager,
	overlay:       ^OverlayManager,
	storage:       ^StorageManager,
	store:         ^StoreManager,
	voice:         ^VoiceManager,
	achievements:  ^AchievementManager,
}

init_managers :: proc "contextless" (c: ^Core, m: ^Managers) {
	m^ = {
		applications  = c->get_application_manager(),
		users         = c->get_user_manager(),
		images        = c->get_image_manager(),
		activities    = c->get_activity_manager(),
		relationships = c->get_relationship_manager(),
		lobbies       = c->get_lobby_manager(),
		network       = c->get_network_manager(),
		overlay       = c->get_overlay_manager(),
		storage       = c->get_storage_manager(),
		store         = c->get_store_manager(),
		voice         = c->get_voice_manager(),
		achievements  = c->get_achievement_manager(),
	}
}

make_managers :: proc "contextless" (c: ^Core) -> (res: Managers) {
	init_managers(c, &res)
	return
}


to_metadata_key :: proc "contextless" (str: string) -> MetadataKey {
	res: MetadataKey = ---
	write_metadata_key(&res, str)
	return res
}
to_metadata_value :: proc "contextless" (str: string) -> MetadataValue {
	res: MetadataValue = ---
	write_metadata_value(&res, str)
	return res
}

write_metadata_key :: proc "contextless" (res: ^MetadataKey, str: string) {
	n := copy(res[:], str)
	res[n] = '\x00'
}
write_metadata_value :: proc "contextless" (res: ^MetadataValue, str: string) {
	n := copy(res[:], str)
	res[n] = '\x00'
}