defmodule DebpressTest do
	use ExUnit.Case
	doctest Debpress

	test "control_file works when given bare minimum Control" do
		control = %Debpress.Control{
			name: "demo",
			version: "0.1",
			architecture: "all",
			maintainer: "nobody",
			depends: [],
			short_description: "a demo",
		}

		assert Debpress.control_file(control) == """
		Package: demo
		Version: 0.1
		Architecture: all
		Maintainer: nobody
		Description: a demo
		"""
	end

	test "control_file works when given all Control options" do
		control = %Debpress.Control{
			name: "demo",
			version: "0.1",
			architecture: "all",
			maintainer: "nobody",
			installed_size_kb: 101,
			pre_depends: ["dpkg (>= 1.14.0)"],
			depends: ["python-twisted", "python (>= 2.7)"],
			provides: ["www-browser", "some-other-thing"],
			section: "misc",
			priority: :optional,
			short_description: "a demo",
			long_description: "It does\nso many things\nthat this file\ncan't even begin\nto describe them"
		}

		assert Debpress.control_file(control) == """
		Package: demo
		Version: 0.1
		Architecture: all
		Maintainer: nobody
		Installed-Size: 101
		Pre-Depends: dpkg (>= 1.14.0)
		Depends: python-twisted, python (>= 2.7)
		Provides: www-browser, some-other-thing
		Priority: optional
		Section: misc
		Description: a demo
		 It does
		 so many things
		 that this file
		 can't even begin
		 to describe them
		"""
	end
end
