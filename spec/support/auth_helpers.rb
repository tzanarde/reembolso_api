module AuthHelpers
  extend RSpec::SharedContext

  def authenticate_user
    post "/users/sign_in", params: { user: { email: user.email,
                                            password: user.password } }.to_json,
                          headers: { "Content-Type" => "application/json",
                                      "ACCEPT" => "application/json" }
    JSON.parse(response.body)["token"]
  end

  def authenticated_user_headers(user_token)
    { "Content-Type" => "application/json",
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer #{user_token}" }
  end

  def unauthenticated_user_headers
    { "Content-Type" => "application/json",
      "ACCEPT" => "application/json" }
  end
end
