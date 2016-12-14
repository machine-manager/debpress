defmodule Debpress do
	alias Gears.FileUtil

	defmodule BadControl do
		defexception message: nil
	end

	defmodule UnexpectedScriptKey do
		defexception message: nil
	end

	defmodule Control do
		@type priority :: :required | :important | :standard | :optional | :extra

		@enforce_keys [:name, :version, :architecture, :maintainer, :depends, :short_description]
		defstruct \
			name:              nil,
			version:           nil,
			architecture:      nil,
			maintainer:        nil,
			installed_size_kb: nil,
			pre_depends:       [],
			depends:           [],
			provides:          [],
			# See docs/sections.html
			section:           nil,
			priority:          nil,
			short_description: nil,
			long_description:  nil
		@type t :: %Control{
			name:              String.t,
			version:           String.t,
			architecture:      String.t,
			maintainer:        String.t,
			installed_size_kb: non_neg_integer() | nil,
			pre_depends:       [String.t],
			depends:           [String.t],
			provides:          [String.t],
			section:           String.t | nil,
			priority:          Control.priority | nil,
			short_description: String.t,
			long_description:  String.t | nil
		}
	end

	# Prefixes every line in some multi-line text with a given prefix string
	@spec prefix_every_line(String.t, String.t) :: String.t
	defp prefix_every_line(text, prefix) do
		text
		|> String.split("\n")
		|> Enum.map(fn line -> prefix <> line end)
		|> Enum.join("\n")
	end

	@doc "Takes a Control struct and returns a string containing a valid control file"
	@spec control_file(Control) :: String.t
	def control_file(c) do
		import Gears.LangUtil, only: [oper_if: 3]

		s = """
		Package: #{c.name}
		Version: #{c.version}
		Architecture: #{c.architecture}
		Maintainer: #{c.maintainer}
		"""
		{s, &Kernel.<>/2}
		|> oper_if(c.installed_size_kb, "Installed-Size: #{c.installed_size_kb}\n")
		|> oper_if(c.pre_depends != [], "Pre-Depends: #{c.pre_depends |> Enum.join(", ")}\n")
		|> oper_if(c.depends     != [], "Depends: #{c.depends   |> Enum.join(", ")}\n")
		|> oper_if(c.provides    != [], "Provides: #{c.provides |> Enum.join(", ")}\n")
		|> oper_if(c.priority,          "Priority: #{c.priority |> Atom.to_string}\n")
		|> oper_if(c.section,           "Section: #{c.section}\n")
		|> oper_if(true,                "Description: #{c.short_description}\n")
		|> oper_if(c.long_description,  prefix_every_line(c.long_description, " ") <> "\n")
		|> elem(0)
	end

	@allowed_script_keys MapSet.new([:preinst, :postinst, :prerm, :postrm])

	@spec write_control_tar_gz(String.t, String.t, %{
		optional(:preinst) => String.t,
		optional(:postinst) => String.t,
		optional(:prerm) => String.t,
		optional(:postrm) => String.t
	}) :: nil
	def write_control_tar_gz(control_tar_gz, control, scripts) do
		temp = FileUtil.temp_dir("debpress")

		for script_key <- Map.keys(scripts) do
			if not MapSet.member?(@allowed_script_keys, script_key) do
				raise UnexpectedScriptKey,
					message: """
						Got unexpected key #{inspect script_key}, \
						which is not one of #{inspect @allowed_script_keys}
						"""
			end
			script_path = Path.join(temp, Atom.to_string(script_key))
			script = Map.get(scripts, script_key)
			File.write!(script_path, script)
			File.chmod!(script_path, 0o700)
		end

		control_file = Path.join(temp, "control")
		File.write!(control_file, control)
		File.chmod!(control_file, 0o600)

		script_files = Map.keys(scripts) |> Enum.map(&Atom.to_string/1)
		{_, 0} = System.cmd("tar",
			["--owner=root", "--group=root", "-C", temp, "-cf", control_tar_gz, "--", "control"] ++ script_files
		)
		nil
	end

	@spec write_deb(String.t, String.t, String.t) :: nil
	def write_deb(out_deb, control_tar_gz, data_tar_xz) do
		temp = FileUtil.temp_dir("debpress")
		d_b = Path.join(temp, "debian-binary")
		File.write!(d_b, "2.0\n")

		FileUtil.rm_f!(out_deb)
		{_, 0} = System.cmd("ar", ["-qc", out_deb, d_b, control_tar_gz, data_tar_xz])
		nil
	end
end
