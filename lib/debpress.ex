defmodule Debpress do
	defmodule Control do
		@type priority :: :required | :important | :standard | :optional | :extra

		@enforce_keys [:name, :version, :architecture, :maintainer, :depends, :short_description]
		defstruct \
			name: nil,
			version: nil,
			architecture: nil,
			maintainer: nil,
			installed_size_kb: nil,
			depends: nil,
			# See docs/sections.html
			section: nil,
			priority: nil,
			short_description: nil,
			long_description: nil
		@type t :: %Control{
			name: String.t,
			version: String.t,
			architecture: String.t,
			maintainer: String.t,
			installed_size_kb: integer() | nil,
			depends: String.t | nil,
			section: String.t | nil,
			priority: Control.priority | nil,
			short_description: String.t,
			long_description: String.t | nil
		}
	end

	@spec prefix_every_line(String.t, String.t) :: String.t
	defp prefix_every_line(text, prefix) do
		text |> String.split("\n") |> Enum.map(fn line -> prefix <> line end) |> String.join("\n")
	end

	@spec make_control(Control) :: String.t
	def make_control(c) do
		s = """
		Package: #{c.name}
		Version: #{c.version}
		Architecture: #{c.architecture}
		Maintainer: #{c.maintainer}
		"""

		if c.installed_size_kb do
			s = s <> "Installed-Size: #{c.installed_size_kb}\n"
		end

		if c.pre_depends do
			s = s <> "Pre-Depends: #{c.pre_depends}\n"
		end

		if c.depends do
			s = s <> "Depends: #{c.depends}\n"
		end

		if c.provides do
			s = s <> "Provides: #{c.provides}\n"
		end

		if c.priority do
			s = s <> "Priority: #{c.priority |> Atom.to_string}\n"
		end

		if c.section do
			s = s <> "Section: #{c.section}\n"
		end

		s = s <> "Description: #{c.short_description}\n"

		if c.long_description do
			s = s <> prefix_every_line(c.long_description, " ") <> "\n"
		end
	end

	@spec write_deb(String.t) :: none
	def write_deb(deb_file) do
		Debpress.Util.rm_f!(deb_file)
		System.cmd("ar", ["-qc", deb_file, "debian-binary", "control.tar.gz", "data.tar.xz"])
	end
end
