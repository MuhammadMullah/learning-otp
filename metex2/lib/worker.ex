defmodule Metex2.Worker do
  use GenServer

  # CLIENT API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_temperature(pid, location) do
    GenServer.call(pid, {:location, location})
  end

  # SERVER API

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:location, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temp} ->
        new_stats = update_stats(stats, location)
        {:reply, "#{temp}°C", new_stats}

      _ ->
        {:reply, :error, stats}
    end
  end

  # HELPER FUNCTIONS
  def temperature_of(location) do
    url_for(location) |> HTTPoison.get() |> parse_response
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!() |> compute_temperature
  end

  defp parse_response(_) do
    :error
  end

  defp compute_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  def apikey do
    "bcc0aaf3330fa435070c703f3bf5873b"
  end

  defp update_stats(old_stats, location) do
    case Map.has_key?(old_stats, location) do
      true ->
        Map.update!(old_stats, location, &(&1 + 1))

      false ->
        Map.put_new(old_stats, location, 1)
    end
  end
end
