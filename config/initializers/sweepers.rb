observers = [InfoSourceSweeper]
Rails.application.config.active_record.observers ||= []
Rails.application.config.active_record.observers += observers
observers.each { |o| o.instance }
