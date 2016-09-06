defmodule Debpress do
	@type Priority.t :: :required | :important | :standard | :optional | :extra

	defmodule Control do
		defstruct
			name: nil,
			version: nil,
			architecture: nil,
			maintainer: "Nobody <nobody@localhost>",
			installed_size_kb: nil,
			depends: nil,
			section: nil,
			priority: :optional,
			short_description: nil
			long_description: ""
		@type t :: %User{name: String.t, age: non_neg_integer}
	end

	@spec make_control(Control) :: String.t
	def make_control() do
		"""
		Package: #{name}
		Version: #{version}
		Architecture: #{architecture}
		Maintainer: #{maintainer}
		Installed-Size: #{installed_size_kb}
		Depends: #{depends}
		Section: #{section}
		Priority: #{priority |> Atom.to_string}
		Description: #{short_description}
		 #{long_description}
		"""
	end

	@spec write_deb(String.t) :: none
	def write_deb(deb_file) do
		Debpress.Util.rm_f!(deb_file)
		System.cmd("ar", ["-qc", deb_file, "debian-binary", "control.tar.gz", "data.tar.xz"])
	end
end
