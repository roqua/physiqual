if Rails.env.development?
  WebMock.allow_net_connect!
end
