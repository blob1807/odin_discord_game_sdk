package c_example

import "base:runtime"
import "core:fmt"
import "core:time"

import discord "./../.."


DISCORD_REQUIRE :: proc "contextless" (x: discord.Result) { assert_contextless( x == .Ok ) }

Application :: struct {
    core:          ^discord.Core,
    users:         ^discord.UserManager,
    achievements:  ^discord.AchievementManager,
    activities:    ^discord.ActivityManager,
    relationships: ^discord.RelationshipManager,
    application:   ^discord.ApplicationManager,
    lobbies:       ^discord.LobbyManager,
    user_id:        discord.UserId,
}

update_activity_callback :: proc "system" (data: rawptr, result: discord.Result) {
    DISCORD_REQUIRE(result)
}

relationship_pass_filter :: proc "system" (data: rawptr, relationship: ^discord.Relationship) -> bool {
    return (relationship.type == .Friend)
}

relationship_snowflake_filter :: proc "system" (data: rawptr, relationship: ^discord.Relationship) -> bool {
    app := (^Application)(data)
    return (relationship.type == .Friend && relationship.user.id < app.user_id)
}

on_relationships_refresh :: proc "system" (data: rawptr) {
    context = runtime.default_context()

    app := (^Application)(data)
    module := app.relationships

    module->filter(app, relationship_pass_filter)

    unfiltered_count: i32
    DISCORD_REQUIRE( module->count(&unfiltered_count) )

    module->filter(app, relationship_snowflake_filter)

    filtered_count: i32
    DISCORD_REQUIRE( module->count(&filtered_count) )

    fmt.println("=== Cool Friends ===")
    for i: i32; i < filtered_count; i += 1 {
        relationship: discord.Relationship
        DISCORD_REQUIRE( module->get_at(i, &relationship) )

        fmt.printfln("%lld %s#%s",
               relationship.user.id,
               relationship.user.username,
               relationship.user.discriminator)
    }
    fmt.printfln("(%v friends less cool than you omitted)", unfiltered_count - filtered_count)

    activity: discord.Activity
    fmt.bprintf(activity.details[:], "Cooler than %d friends", unfiltered_count - filtered_count)
    fmt.bprint(activity.state[:], unfiltered_count, "friends total")

    app->activities->update_activity(&activity, app, update_activity_callback)
}


on_user_updated :: proc "system" (data: rawptr) {
    app := (^Application)(data)
    user: discord.User
    app->users->get_current_user(&user)
    app.user_id = user.id
}

on_oauth2_token :: proc "system" (data: rawptr, result: discord.Result, token: ^discord.OAuth2Token) {
    context = runtime.default_context()
    if (result == .Ok) {
        fmt.printfln("OAuth2 token: %s", token.access_token)
    }
    else {
        fmt.printfln("GetOAuth2Token failed with %v", result)
    }
}

on_lobby_connect :: proc "system" (data: rawptr, result: discord.Result, lobby: ^discord.Lobby) {
    context = runtime.default_context()
    fmt.printf("LobbyConnect returned %v\n", result)
}

main :: proc() {
    app: Application
    users_events: discord.UserEvents
    users_events.on_current_user_update = on_user_updated

    activities_events: discord.ActivityEvents
    relationships_events: discord.RelationshipEvents
    relationships_events.on_refresh = on_relationships_refresh

    params: discord.CreateParams
    discord.CreateParamsSetDefault(&params)
    params.client_id           = 418559331265675294
    params.flags               = .Default
    params.event_data          = &app
    params.activity_events     = &activities_events
    params.relationship_events = &relationships_events
    params.user_events         = &users_events
    DISCORD_REQUIRE( discord.Create(discord.VERSION, &params, &app.core) )

    app = {
        users        = app.core->get_user_manager(),
        achievements = app.core->get_achievement_manager(),
        activities   = app.core->get_activity_manager(),
        application  = app.core->get_application_manager(),
        lobbies      = app.core->get_lobby_manager(),
    }

    secret: discord.LobbySecret
    copy(secret[:], "invalid_secret")
    app.lobbies->connect_lobby_with_activity_secret(secret, &app, on_lobby_connect)

    app.application->get_oauth2_token(&app, on_oauth2_token)

    branch: discord.Branch
    app.application->get_current_branch(&branch)
    fmt.printf("Current branch %s\n", branch)

    app.relationships = app.core->get_relationship_manager()

    for {
        DISCORD_REQUIRE(app.core->run_callbacks())
        time.sleep(time.Millisecond * 16)
    }

    return
}