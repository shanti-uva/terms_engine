require 'test_helper'

class DefinitionRelationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @definition_relation = definition_relations(:one)
  end

  test "should get index" do
    get definition_relations_url
    assert_response :success
  end

  test "should get new" do
    get new_definition_relation_url
    assert_response :success
  end

  test "should create definition_relation" do
    assert_difference('DefinitionRelation.count') do
      post definition_relations_url, params: { definition_relation: { ancestor_ids: @definition_relation.ancestor_ids, child_node_id: @definition_relation.child_node_id, parent_node_id: @definition_relation.parent_node_id } }
    end

    assert_redirected_to definition_relation_url(DefinitionRelation.last)
  end

  test "should show definition_relation" do
    get definition_relation_url(@definition_relation)
    assert_response :success
  end

  test "should get edit" do
    get edit_definition_relation_url(@definition_relation)
    assert_response :success
  end

  test "should update definition_relation" do
    patch definition_relation_url(@definition_relation), params: { definition_relation: { ancestor_ids: @definition_relation.ancestor_ids, child_node_id: @definition_relation.child_node_id, parent_node_id: @definition_relation.parent_node_id } }
    assert_redirected_to definition_relation_url(@definition_relation)
  end

  test "should destroy definition_relation" do
    assert_difference('DefinitionRelation.count', -1) do
      delete definition_relation_url(@definition_relation)
    end

    assert_redirected_to definition_relations_url
  end
end
