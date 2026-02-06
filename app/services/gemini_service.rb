# frozen_string_literal: true

require "net/http"
require "json"

class GeminiService
  API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"

  class << self
    # 取り戻した時間（分）を元に、AIが過ごし方を提案する
    def suggest_time_usage(minutes:, amount: nil)
      return nil unless api_key_present?

      prompt = build_prompt(minutes, amount)
      call_api(prompt)
    rescue StandardError => e
      Rails.logger.error("[GeminiService] API呼び出しエラー: #{e.message}")
      nil
    end

    private

    def api_key_present?
      ENV["GEMINI_API_KEY"].present?
    end

    def build_prompt(minutes, amount)
      base = <<~PROMPT
        あなたは「節約で取り戻した自由な時間」の使い方を提案するアシスタントです。

        ユーザーは節約して#{minutes}分の自由な時間を取り戻しました。
        #{"節約額は¥#{amount}です。" if amount}

        この#{minutes}分でできる、具体的で素敵な過ごし方を1つだけ提案してください。

        ルール：
        - 1〜2文で簡潔に（50文字以内が理想）
        - 具体的な行動を提案（「読書」ではなく「好きなカフェで文庫本を3ページ」のように）
        - 心が温まる、または少しワクワクする内容
        - 実際にその分数で可能なこと
        - 絵文字を1つだけ冒頭につける
        - 余計な説明や前置きは不要。提案文のみ返してください。
      PROMPT
      base.strip
    end

    def call_api(prompt)
      uri = URI("#{API_URL}?key=#{ENV['GEMINI_API_KEY']}")

      request_body = {
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ],
        generationConfig: {
          temperature: 0.9,
          maxOutputTokens: 100
        }
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = request_body.to_json

      response = http.request(request)

      if response.code == "200"
        data = JSON.parse(response.body)
        extract_text(data)
      else
        Rails.logger.error("[GeminiService] API応答エラー: #{response.code} - #{response.body}")
        nil
      end
    end

    def extract_text(data)
      text = data.dig("candidates", 0, "content", "parts", 0, "text")
      text&.strip
    end
  end
end
