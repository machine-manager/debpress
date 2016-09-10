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
			pre_depends: [],
			depends: [],
			provides: [],
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
			pre_depends: [String.t],
			depends: [String.t],
			provides: [String.t],
			section: String.t | nil,
			priority: Control.priority | nil,
			short_description: String.t,
			long_description: String.t | nil
		}
	end

	@docp "Prefixes every line in some multi-line text with a given prefix string"
	@spec prefix_every_line(String.t, String.t) :: String.t
	defp prefix_every_line(text, prefix) do
		text |> String.split("\n") |> Enum.map(fn line -> prefix <> line end) |> Enum.join("\n")
	end

	@doc "Takes a Control struct and returns a string containing a valid control file"
	@spec control_file(Control) :: String.t
	def control_file(c) do
		import Debpress.Util, only: [append_if: 3]

		"""
		Package: #{c.name}
		Version: #{c.version}
		Architecture: #{c.architecture}
		Maintainer: #{c.maintainer}
		"""
		|> append_if(c.installed_size_kb, "Installed-Size: #{c.installed_size_kb}\n")
		|> append_if(c.pre_depends != [], "Pre-Depends: #{c.pre_depends |> Enum.join(", ")}\n")
		|> append_if(c.depends != [], "Depends: #{c.depends |> Enum.join(", ")}\n")
		|> append_if(c.provides != [], "Provides: #{c.provides |> Enum.join(", ")}\n")
		|> append_if(c.priority, "Priority: #{c.priority |> Atom.to_string}\n")
		|> append_if(c.section, "Section: #{c.section}\n")
		|> Kernel.<>("Description: #{c.short_description}\n")
		|> append_if(c.long_description, prefix_every_line(c.long_description, " ") <> "\n")
	end

	@spec write_deb(String.t) :: nil
	def write_deb(deb_file) do
		Debpress.Util.rm_f!(deb_file)
		{_, 0} = System.cmd("ar", ["-qc", deb_file, "debian-binary", "control.tar.gz", "data.tar.xz"])
		nil
	end
end
