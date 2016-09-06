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
		[applications: [:logger]]
	end

	defp deps do
		[]
	end
end