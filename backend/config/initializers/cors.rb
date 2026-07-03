Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*" # tighten this for production; fine for a local assignment build
    resource "/api/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Content-Disposition"]
    resource "/rails/active_storage/*",
      headers: :any,
      methods: [:get, :head]
  end
end
