defmodule SampleWorker do
  use WorkerPool.Worker

  @impl true
  def work(pid), do: send(pid, :ok)
end
