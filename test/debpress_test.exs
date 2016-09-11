defmodule DebpressTest do
	use ExUnit.Case
	doctest Debpress

	test "can't construct a Control without mandatory keys" do
		msg = ~r(following keys must also be given)

		# We use eval_string because otherwise this test file can't
		# even be compiled.
		_ = assert_raise ArgumentError, msg, fn ->
			Code.eval_string(~s(%Debpress.Control{}))
		end

		assert_raise ArgumentError, msg, fn ->
			Code.eval_string(~s(%Debpress.Control{name: "name"}))
		end

		assert_raise ArgumentError, msg, fn ->
			Code.eval_string(~s(%Debpress.Control{name: "name", version: "1.0"}))
		end

		assert_raise ArgumentError, msg, fn ->
			Code.eval_string(~s(%Debpress.Control{name: "name", version: "1.0", architecture: "amd64"}))
		end

		assert_raise ArgumentError, msg, fn ->
			Code.eval_string(~s(%Debpress.Control{
				name: "name",
				version: "1.0",
				architecture: "amd64",
				maintainer: "nobody"
			}))
		end

		assert_raise ArgumentError, msg, fn ->
			Code.eval_string(~s(%Debpress.Control{
				name: "name",
				version: "1.0",
				architecture: "amd64",
				maintainer: "nobody",
				depends: []
			}))
		end

		# This one works
		Code.eval_string(~s(%Debpress.Control{
			name: "name",
			version: "1.0",
			architecture: "amd64",
			maintainer: "nobody",
			depends: [],
			short_description: "hello"
		}))
	end

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
			installed_size_kb: "101",
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

	test "write_control_tar_gz works with empty scripts Map" do
		temp = Debpress.Util.temp_dir("debpress_test")
		control_tar_gz = Path.join(temp, "control.tar.gz")

		Debpress.write_control_tar_gz(control_tar_gz, "my control file", %{})

		assert File.regular?(control_tar_gz)
		size = File.stat!(control_tar_gz).size
		assert size > 0
	end

	test "write_control_tar_gz works with non-empty scripts Map" do
		temp = Debpress.Util.temp_dir("debpress_test")
		control_tar_gz = Path.join(temp, "control.tar.gz")

		Debpress.write_control_tar_gz(control_tar_gz, "my control file", %{preinst: "preinst"})

		assert File.regular?(control_tar_gz)
		size = File.stat!(control_tar_gz).size
		assert size > 0

		scripts = %{preinst: "preinst", postinst: "postinst", prerm: "prerm", postrm: "postrm"}
		Debpress.write_control_tar_gz(control_tar_gz, "my control file", scripts)

		assert File.regular?(control_tar_gz)
		size = File.stat!(control_tar_gz).size
		assert size > 0
	end

	test "write_control_tar_gz raises UnexpectedScriptKey when given invalid key" do
		assert_raise Debpress.UnexpectedScriptKey, fn ->
			Debpress.write_control_tar_gz("", "my control file", %{invalid: ""})
		end
	end

	test "write_deb works" do
		temp = Debpress.Util.temp_dir("debpress_test")

		control_tar_gz = Path.join(temp, "control.tar.gz")
		data_tar_xz = Path.join(temp, "data.tar.xz")
		File.write!(control_tar_gz, "")
		File.write!(data_tar_xz, "")

		out_deb = Path.join(temp, "out.deb")
		Debpress.write_deb(out_deb, control_tar_gz, data_tar_xz)

		assert File.regular?(out_deb)
		size = File.stat!(out_deb).size
		assert size > 0

		# Calling write_deb again overwrites the existing file
		Debpress.write_deb(out_deb, control_tar_gz, data_tar_xz)
		assert File.stat!(out_deb).size == size
	end
end
