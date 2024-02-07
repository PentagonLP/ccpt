local commands = require("lib.ccpt.command")


local ccptData = {}


-- Link to a list of packages that are present by default (used in 'update()')
ccptData.defaultpackageurl = "https://raw.githubusercontent.com/hpf3/ccpt/main/defaultpackages.json"

-- CONFIG ARRAYS --
--[[ Array to store subcommands, help comment and function
]]--
ccptData.actions = {
	update = {
		func = commands.update,
		comment = "Search for new Versions & Packages"
	},
	install = {
		func = commands.install.install,
		comment = "Install new Packages"
	},
	upgrade = {
		func = commands.upgrade.upgrade,
		comment = "Upgrade installed Packages"
	},
	uninstall = {
		func = commands.uninstall.uninstall,
		comment = "Remove installed Packages"
	},
	add = {
		func = commands.add,
		comment = "Add Package URL to local list"
	},
	remove = {
		func = commands.remove,
		comment = "Remove Package URL from local list"
	},
	list = {
		func = commands.list,
		comment = "List installed and able to install Packages"
	},
	info = {
		func = commands.info,
		comment = "Information about a package"
	},
	startup = {
		func = commands.startup
	},
	help = {
		func = commands.help,
		comment = "Print help"
	},
	version = {
		func = commands.version,
		comment = "Print CCPT Version"
	},
	zzzzzz = {
		func = commands.zzzzzz
	},
	boom = {
		func = commands.boom
	}
} 

--[[ Array to store different installation methodes and corresponding functions
]]--
ccptData.installtypes = {
	library = {
		install = commands.install.installlibrary,
		update = commands.install.installlibrary,
		remove = commands.uninstall.removelibrary,
		desc = "Single file library"
	},
	script = {
		install = commands.install.installscript,
		update = commands.upgrade.updatescript,
		remove = commands.uninstall.removescript,
		desc = "Programm installed via Installer"
	}
}



return ccptData