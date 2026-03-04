namespace ExtraMenuBar {
    shared string RandomString(const uint length) {
        string ret;
        for (uint i = 0; i < length; i++) {
            ret += " ";
            ret[i] = Math::Rand(32, 127);
        }

        return ret;
    }

    shared abstract class Item {
        bool enabled = true;

        private string _id = "###" + RandomString(16);
        string get_id() final { return _id; }

        private string _label;
        string get_label() final { return _label; }

        Item(const string&in label) {
            UpdateLabel(label);
        }

        void Render() { }

        void RenderIfEnabled() final {
            if (enabled) {
                Render();
            }
        }

        void UpdateLabel(const string&in new = "") final {
            if (new.Contains("##")) {
                throw("you cannot set a new ID for an item");
            }

            _label = new + id;
        }
    }

    shared abstract class ContainerItem : Item {
        protected Item@[] items;

        uint get_Length() {
            return items.Length;
        }

        ContainerItem(const string&in label) {
            super(label);
        }

        Item@ opIndex(const uint index) {
            return index < Length ? items[index] : null;
        }

        Item@ opIndex(const string&in label) {
            const int index = FindByLabel(label);
            return index != -1 ? this[index] : null;
        }

        int FindByLabel(const string&in label) {
            for (uint i = 0; i < Length; i++) {
                if (items[i].label == label or items[i].label.Split("###")[0] == label) {
                    return i;
                }
            }

            return -1;
        }

        int FindByRef(Item@ item) {
            return item !is null ? items.FindByRef(item) : -1;
        }

        bool IsEmpty() {
            return items.IsEmpty();
        }

        void InsertAt(const uint index, Item@ item) {
            if (FindByRef(item) == -1) {
                items.InsertAt(index, @item);
            }
        }

        void InsertLast(Item@ item) {
            if (FindByRef(item) == -1) {
                items.InsertLast(@item);
            }
        }

        void MoveTo(const uint index, Item@ item) {
            if (index <= Length) {
                Remove(item);
                InsertAt(index, item);
            }
        }

        void Remove(Item@ item) {
            if (item !is null) {
                const int index = FindByRef(item);
                if (index != -1) {
                    items.RemoveAt(index);
                }
            }
        }

        void Remove(const string&in label) {
            const int index = FindByLabel(label);
            if (index != -1) {
                items.RemoveAt(index);
            }
        }

        void RemoveAt(const uint index) {
            if (index < Length) {
                items.RemoveAt(index);
            }
        }
    }

    shared class Menu : ContainerItem {
        Menu(const string&in label) {
            super(label);
        }

        void Render() override {
            UI::BeginDisabled(IsEmpty());

            if (UI::BeginMenu(label)) {
                for (uint i = 0; i < Length; i++) {
                    items[i].Render();
                }

                UI::EndMenu();
            }

            UI::EndDisabled();
        }
    }

    shared abstract class DynamicItem : Item {
        protected CoroutineFunc@ action;

        DynamicItem(const string&in label) {
            super(label);
        }

        void opCall() {
            if (action !is null) {
                action();
            }
        }

        void RegisterAction(CoroutineFunc@ func) final {
            @action = func;
        }

        void UnregisterAction() final {
            @action = null;
        }
    }

    shared class Button : DynamicItem {
        Button(const string&in label) {
            super(label);
        }

        void Render() override {
            if (UI::Button(label)) {
                this();
            }
        }
    }

    shared abstract class BooleanItem : DynamicItem {
        bool state = false;

        BooleanItem(const string&in label) {
            super(label);
        }
    }

    shared class Checkbox : BooleanItem {
        Checkbox(const string&in label) {
            super(label);
        }

        void Render() override {
            const bool pre = state;
            state = UI::Checkbox(label, state);
            if (state != pre) {
                this();
            }
        }
    }

    shared class RadioButton : BooleanItem {
        RadioButton(const string&in label) {
            super(label);
        }

        void Render() override {
            const bool pre = state;
            state = UI::RadioButton(label, state);
            if (state != pre) {
                this();
            }
        }
    }

    shared class Text : Item {
        Text(const string&in label = "") {
            super(label);
        }

        void Render() override {
            UI::Text(label.Split("###")[0]);
        }
    }
}
