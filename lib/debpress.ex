defmodule Debpress do
	defmodule BadControl do
		defexception message: nil
	end

	defmodule Control do
		@type priority :: :required | :important | :standard | :optional | :extra

		@enforce_keys [:name, :version, :architecture, :maintainer, :depends, :short_description]
		defstruct \
			name: nil,
			version: nil,
			architecture: nil,
			maintainer: nil,
			installed_size_kb: nil,
			pre_depends: nil,
			depends: nil,
			provides: nil,
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
			installed_size_kb: non_neg_integer() | nil,
			pre_depends: String.t | nil,
			depends: String.t | nil,
			provides: String.t | nil,
			section: String.t | nil,
			priority: Control.priority | nil,
			short_description: String.t,
			long_description: String.t | nil
		}
	end

	@doc "Prefixes every line in some multi-line text with a given prefix string"
	@spec prefix_every_line(String.t, String.t) :: String.t
	defp prefix_every_line(text, prefix) do
		text |> String.split("\n") |> Enum.map(fn line -> prefix <> line end) |> Enum.join("\n")
	end

	@doc "Takes a Control struct and returns a string containing a valid control file"
	@spec make_control(Control) :: String.t
	def make_control(c) do
		s = """
		Package: #{c.name}
		Version: #{c.version}
		Architecture: #{c.architecture}
		Maintainer: #{c.maintainer}
		"""
		s = if c.installed_size_kb, do: s <> "Installed-Size: #{c.installed_size_kb}\n", else: s
		s = if c.pre_depends, do: s <> "Pre-Depends: #{c.pre_depends}\n", else: s
		s = if c.depends, do: s <> "Depends: #{c.depends}\n", else: s
		s = if c.provides, do: s <> "Provides: #{c.provides}\n", else: s
		s = if c.priority, do: s <> "Priority: #{c.priority |> Atom.to_string}\n", else: s
		s = if c.section, do: s <> "Section: #{c.section}\n", else: s
		s = s <> "Description: #{c.short_description}\n"
		s = if c.long_description, do: s <> prefix_every_line(c.long_description, " ") <> "\n", else: s
		s
	end

	@spec write_deb(String.t) :: none
	def write_deb(deb_file) do
		Debpress.Util.rm_f!(deb_file)
		System.cmd("ar", ["-qc", deb_file, "debian-binary", "control.tar.gz", "data.tar.xz"])
	end
end
