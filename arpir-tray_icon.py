
#!/usr/bin/env python3
import gi
import subprocess
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')
from gi.repository import Gtk, AppIndicator3, Pango

def execute_script(command):
    subprocess.Popen(['bash', '/usr/local/bin/Arpir-Obfuscation-Engine/arpir-obfuscation-engine.sh'] + command.split())
    print(f"Script executed with command: {command}")

class TrayIconApp:
    def __init__(self):
        icon_path = "/usr/local/bin/Arpir-Obfuscation-Engine/_bin/Vault-Arpir.png"  # Path to the converted PNG icon

        self.indicator = AppIndicator3.Indicator.new(
            "vault-manager",  # Unique ID for the app indicator
            icon_path,
            AppIndicator3.IndicatorCategory.APPLICATION_STATUS)
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.create_menu())

    def create_menu(self):
        menu = Gtk.Menu()

        # Define all the menu items with their corresponding bash arguments and descriptions
        menu_items = {
            'Mount Vault': ('--mount-vault', 'Select and mount your encrypted vault'),
            'Exit Vault': ('--exit-vault', 'Safely exit and close your vault'),            
            'Create Vault': ('--create-vault', 'Create a new encrypted vault'),
            'New Container Setup': ('--new-container-setup', 'Guided setup for new containers including vault and decoy configuration.'),
            'Setup Decoy Container': ('--setup-decoy-container', 'Setup a decoy container for obfuscation'),
            'Setup Mass Obfuscation': ('--setup-mass-obfuscation', 'Configure mass data obfuscation'),
            'Change Password': ('--change-password', 'Change your vault\'s password'),
            'Randomize Access Data': ('--randomize-access-data', 'Randomize timestamps for all /user/ files. May take a long time to complete.'),
            'Help': ('--help', 'Display help information')
        }

        # Add menu items dynamically with descriptions and separators
        for label, (command, description) in menu_items.items():
            item = Gtk.MenuItem()
            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            label_widget = Gtk.Label(label=label, xalign=0)
            desc_label = Gtk.Label(label=description, xalign=0)
            desc_label.set_use_markup(True)
            desc_label.set_markup('<span size="smaller">' + description + '</span>')
            box.pack_start(label_widget, True, True, 0)
            box.pack_start(desc_label, True, True, 0)
            item.add(box)
            item.connect('activate', lambda _, cmd=command: execute_script(cmd))
            menu.append(item)

            separator = Gtk.SeparatorMenuItem()
            menu.append(separator)

        # Add quit item
        item_quit = Gtk.MenuItem(label='Quit this manager')
        item_quit.connect('activate', self.quit)
        menu.append(item_quit)

        menu.show_all()
        return menu

    def quit(self, _):
        Gtk.main_quit()

    def run(self):
        Gtk.main()

if __name__ == "__main__":
    app = TrayIconApp()
    app.run()
