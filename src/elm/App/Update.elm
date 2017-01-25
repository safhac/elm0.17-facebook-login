module App.Update exposing (init, update, updateWithStorage, Msg(..))

import App.Model exposing (..)
import User.Model exposing (..)


-- MESSAGE

type Msg
    = NoOp
    | Login
    | Logout
    | LoggedIn String
    | LoggedOut String
    | UserMsg User.Msg



-- INIT


init : Maybe (Encode.Value) -> ( AppModel, Cmd Msg )
init savedModel =
    case savedModel of
        Just value  ->
            let _ = 
                Debug.log "init value " value
            in
                Maybe.withDefault initialModel (Decode.decodeValue modelDecoder value |> resultToMaybe ) ! []
        _ -> 
            initialModel ! [] 



-- UPDATE


updateWithStorage : Msg -> AppModel -> ( AppModel, Cmd Msg )
updateWithStorage msg model =
    let
        ( newModel, cmds ) =
            update msg model
        _ = Debug.log "updateWithStorage " msg
        
    in
        ( newModel
        , Cmd.batch [ setStorage (User.modelToValue newModel.userModel), cmds ]
        )


update : Msg -> AppModel -> ( AppModel, Cmd Msg )
update msg model =
    case msg of
        LoggedIn json ->
            let
                ( updatedUserModel, userCmd ) =
                    User.update (User.UserLoggedIn json) model.userModel
                _ = Debug.log "update LoggedIn " json
            in
                ( { model | userModel = updatedUserModel }, Cmd.map UserMsg userCmd )

        LoggedOut loggedOutMsg ->
            let
                ( updatedUserModel, userCmd ) =
                    User.update (User.UserLoggedOut loggedOutMsg) model.userModel
                _ = Debug.log "update LoggedOut " loggedOutMsg
            in
                ( { model | userModel = updatedUserModel }, Cmd.none )

        Login ->
            let 
                _ = Debug.log "update Login " Login
            in
                ( model, Facebook.login {} )

        Logout ->
            let 
                _ = Debug.log "update Login " Login
            in
                ( model, Facebook.logout {} )

        _ ->
            ( model, Cmd.none )

            