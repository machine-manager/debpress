defmodule Debpress.Mixfile do
	use Mix.Project

	def project do
		[
			app: :debpress,
			version: "0.1.0",
			elixir: "~> 1.4-dev",
			build_embedded: Mix.env == :prod,
			start_permanent: Mix.env == :prod,
			deps: deps()
		]
	end

	def application do
		[applications: [:logger, :ex_unit]]
	end

	defp deps do
		[
			{:gears, "~> 0.1.0"},
			{:dialyxir, "~> 0.3.5", only: :dev}
		]
	end
end
