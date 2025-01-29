require 'rails_helper'

RSpec.describe "Admin::Assistants", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/admin/assistant/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/assistant/create"
      expect(response).to have_http_status(:success)
    end
  end

end
