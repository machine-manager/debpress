defmodule Debpress do
	@type Priority.t :: :required | :important | :standard | :optional | :extra

	defmodule Control do
		@enforce_keys [:name, :version, :architecture, :depends, :short_description]
		defstruct
			name: nil,
			version: nil,
			architecture: nil,
			maintainer: "Nobody <nobody@localhost>",
			installed_size_kb: 0,
			depends: nil,
			# See docs/sections.html
			section: nil,
			priority: nil,
			short_description: nil
			long_description: ""
		@type t :: %User{name: String.t, age: non_neg_integer}
	end

	@spec prefix_every_line()
	defp prefix_every_line(text, prefix) do
		text |> String.split("\n") |> Enum.map(fn line -> prefix <> line end)
	end

	@spec make_control(Control) :: String.t
	def make_control(c) do
		"""
		Package: #{name}
		Version: #{version}
		Architecture: #{architecture}
		Maintainer: #{maintainer}
		"""

		if installed_size_kb do
			s = s <> "Installed-Size: #{c.installed_size_kb}\n"
		end

		if pre_depends do
			s = s <> "Pre-Depends: #{c.pre_depends}\n"
		end

		if depends do
			s = s <> "Depends: #{c.depends}\n"
		end

		if provides do
			s = s <> "Provides: #{c.provides}\n"
		end

		if priority do
			s = s <> "Priority: #{c.priority |> Atom.to_string}\n"
		end

		if section do
			s = s <> "Section: #{c.section}\n"
		end

		s = s <> "Description: #{c.short_description}\n"

		if long_description do
			s = s <> prefix_every_line(long_description, " ") <> "\n"
		end
	end

	@spec write_deb(String.t) :: none
	def write_deb(deb_file) do
		Debpress.Util.rm_f!(deb_file)
		System.cmd("ar", ["-qc", deb_file, "debian-binary", "control.tar.gz", "data.tar.xz"])
	end
end
