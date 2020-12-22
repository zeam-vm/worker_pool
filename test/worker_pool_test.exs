defmodule WorkerPoolTest do
  use ExUnit.Case
  doctest WorkerPool

  setup_all do
    {:ok, pid} = WorkerPool.start_link(SampleWorker)
    {:ok, pool: pid}
  end

  test "Ensure loaded? test/support/sample_worker.ex" do
    assert Code.ensure_loaded?(SampleWorker)
  end

  test "Sample Worker" do
    WorkerPool.get_worker(SampleWorker) |> send({:work, self()})
    assert_receive :ok, 1000
  end
end
