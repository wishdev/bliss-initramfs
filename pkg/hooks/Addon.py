# Copyright 2012-2015 Jonathan Vasquez <jvasquez1011@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.

from pkg.hooks.Hook import Hook

class Addon(Hook):
    # A list of kernel modules to include in the initramfs
    # Format: "module1", "module2", "module3", ...
    _files = [
        # Uncomment the module below if you have encryption support built as a module, rather than built into the kernel:
        #"dm-crypt",

        # Add your modules below
        #"i915",
        #"nouveau",
    ]
