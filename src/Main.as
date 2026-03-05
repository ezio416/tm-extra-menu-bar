const string  pluginColor = "\\$0F4";
const string  pluginIcon  = Icons::Heartbeat;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

ExtraMenuBar::Text     clock;
ExtraMenuBar::Text     fps;
ExtraMenuBar::Item@[]  items;
ExtraMenuBar::Menu     mainMenu(pluginColor + pluginIcon + "\\$G Openplanet");
ExtraMenuBar::Checkbox mainMenuClock("Clock");
ExtraMenuBar::Checkbox mainMenuFps("FPS");
bool                   shown = true;

void Main() {
    OnSettingsChanged();

    mainMenu.InsertLast(mainMenuFps);
    mainMenu.InsertLast(mainMenuClock);
    items.InsertLast(mainMenu);

    items.InsertLast(fps);
    items.InsertLast(clock);
}

void OnSettingsChanged() {
    fps.enabled = mainMenuFps.state = S_FPS;
    clock.enabled = mainMenuClock.state = S_Clock;
}

void Render() {
    if (false
        or !S_Enabled
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and !S_DebugAlwaysShow
            and UI::IsOverlayShown()
        )
    ) {
        shown = false;
        return;
    }

    shown = true;

    const float scale = UI::GetScale();

    int flags = 0
        | UI::WindowFlags::MenuBar
        | UI::WindowFlags::NoCollapse
        | UI::WindowFlags::NoFocusOnAppearing
        | UI::WindowFlags::NoMove
        | UI::WindowFlags::NoNav
        | UI::WindowFlags::NoNavInputs
        | UI::WindowFlags::NoNavFocus
        | UI::WindowFlags::NoResize
        | UI::WindowFlags::NoTitleBar
    ;

    // const float barHeight = scale * 23.5f;

    // if (UI::GetMousePos().y > barHeight) {
    //     flags |= UI::WindowFlags::NoInputs;
    // }

    UI::SetNextWindowPos(0, S_PositionY, UI::Cond::Always);
    UI::SetNextWindowSize(int(Display::GetWidth() / scale) + 1, 0, UI::Cond::Always);
    UI::PushStyleColor(UI::Col::WindowBg, vec4());
    UI::PushStyleVar(UI::StyleVar::WindowRounding, 0.0f);

    if (UI::Begin(pluginTitle + "###main-" + pluginMeta.ID, S_Enabled, flags)) {
        UI::BeginMenuBar();

        for (uint i = 0; i < items.Length; i++) {
            items[i].RenderIfEnabled();
        }

        UI::EndMenuBar();
    }

    UI::End();

    UI::PopStyleVar();
    UI::PopStyleColor();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void Update(float) {
    if (!shown) {
        return;
    }

    S_FPS = fps.enabled = mainMenuFps.state;
    fps.UpdateLabel(int(Math::Round(GetApp().Viewport.AverageFps)) + " FPS");

    S_Clock = clock.enabled = mainMenuClock.state;
    clock.UpdateLabel(Time::FormatString("%X"));
}
