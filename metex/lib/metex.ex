defmodule Metex do
  alias Metex.Coordinator
  alias Metex.Worker

  def temperatures_of(cities) do
    coordinator_pid = spawn(Coordinator, :loop, [[], Enum.count(cities)])

    cities |> Enum.each(fn city ->
      worker_pid = spawn(Worker, :loop, [])
      send(worker_pid, {coordinator_pid, city})
     end)
  end
end
