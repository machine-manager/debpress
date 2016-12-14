defmodule Debpress.Mixfile do
	use Mix.Project

	def project do
		[
			app: :debpress,
			version: "0.2.3",
			elixir: "~> 1.4",
			build_embedded: Mix.env == :prod,
			start_permanent: Mix.env == :prod,
			deps: deps()
		]
	end

	defp deps do
		[
			{:gears, "~> 0.6.0"},
			{:dialyxir, "~> 0.3.5", only: :dev}
		]
	end
end
