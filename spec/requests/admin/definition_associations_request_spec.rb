require 'rails_helper'

RSpec.describe "Admin::DefinitionAssociations", type: :request do

  describe "GET /create" do
    it "returns http success" do
      get "/admin/definition_association/create"
      expect(response).to have_http_status(:success)
    end
  end

end
