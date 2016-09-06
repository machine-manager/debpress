defmodule Debpress.Util do
	@doc """
	Unlinks `path` if it exists.  Must be a file or an empty directory.
	The parent directories must exist in any case.
	"""
	def rm_f!(path) do
		case File.rm(path) do
			:ok -> nil
			{:error, :enoent} -> nil
			{:error, reason} ->
				raise File.Error, reason: reason, action: "rm", path: path
		end
	end
end
