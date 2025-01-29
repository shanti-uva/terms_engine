require 'openai'

class Admin::AssistantsController < AclController
  
  # GET /assistant . No id because it is a singular resource (resource :assistant)
  def show
    tibetan = Language.get_by_code('bod')
    @dictionaries = InfoSource.where(language_id: tibetan.id).order(:position)
    @languages = Language.all.order(:name)
    @assistant = Assistant.new
    @prompt = ''
    @translations = {}
    @terms = []
    @definitions = []
  end
  
  # POST /assistants
  def create
    tibetan = Language.get_by_code('bod')
    @dictionaries = InfoSource.where(language_id: tibetan.id).order(:position)
    @languages = Language.all.order(:name)
    @assistant = Assistant.new(assistant_params)
    dicts = @assistant.base_dictionary.nil? ? 1 : @assistant.base_dictionary.code
    parsed_text = ShantiIntegration::TranslationTool.translate(@assistant.passage, dicts: dicts)
    @terms = []
    @fids = []
    @definitions = []
    parsed_text['words'].each do |term, defs|
      next if defs.empty?
      @terms << CGI.unescapeHTML(term)
      @fids << defs.second.to_i
      if !@assistant.base_dictionary.nil?
        definitions_hash = {}
        i=0
        while i<defs.size
          tag = defs[i]
          definitions_hash[tag] ||= []
          definitions_hash[tag] << defs[i+1]
          i+=2
        end
        @definitions << (definitions_hash[@assistant.base_dictionary.code].nil? ? '' : definitions_hash[@assistant.base_dictionary.code].join(". "))
      end
    end
    if @assistant.translated_passage.blank? || current_user.access_token.blank?
      @translations = {}
    else
      @prompt = "When translating the passage \"#{@assistant.passage.gsub(/[\n\v\r]/, " ")}\" into #{@assistant.language.name} like as \"#{@assistant.translated_passage.gsub(/[\n\v\r]/, " ")}\""
      @prompt << "How were the following Tibetan terms exactly translated? " + @terms.join(", ")
      @prompt << "Give response as a JSON object with the keys being all terms exactly as they were provided and the value its corresponding translation without any additional text or explanation. Put verbs in infinitive."
      # Initialize OpenAI client
      client = OpenAI::Client.new(access_token: current_user.access_token)
      # Call ChatGPT API
      response = client.chat(
        parameters: {
          model: "gpt-4o-mini", # Required.
          messages: [{ role: "user", content: @prompt}], # Required.
          temperature: 0.1
        }
      )
      raw_json = response.dig("choices", 0, "message", "content")
      clean_json = raw_json.gsub(/```json\n|\n```/, '')
      @translations = JSON.parse(clean_json)
    end
    respond_to do |format|
      format.html { render 'show' }
    end
  end
  
  private
    # Only allow a list of trusted parameters through.
    def assistant_params
      params.require(:assistant).permit(:passage, :translated_passage, :base_dictionary_id, :destination_dictionary_id, :language_id)
    end
  
end
