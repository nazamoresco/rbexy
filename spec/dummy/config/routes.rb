Rails.application.routes.draw do
  get "rbx_view" => "rbx_view#index"
  get "controller_context" => "context#index"
  get "perf_test", to: "perf_test#index"
end
