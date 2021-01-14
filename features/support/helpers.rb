# frozen_string_literal: true

# Common Methods to Use in Page Calls
module Helpers
  def wait_for_pageload
    300.times do
      begin
        page.execute_script('return document.readyState').eql?('complete')
        break
      rescue StandardError
        sleep 0.1
      end
    end
  end

  def wait_for_file_existence(filename)
    300.times do
      begin
        FileTest.exist?(filename)
        break
      rescue StandardError
        sleep 0.1
      end
    end
  end

  def wait_to_delete_file(filename)
    300.times do
      begin
        File.delete(filename)
        break
      rescue StandardError
        sleep 0.1
      end
    end
  end

  def wait_until_text_match(element, pattern)
    300.times do
      begin
        find(element, wait: 0.5).text.match(pattern)
        break
      rescue StandardError
        sleep 0.1
      end
    end
  end

  def wait_until_text_exist(element, text)
    300.times do
      begin
        find(element, wait: 0.5).assert_text(text)
        break
      rescue StandardError
        sleep 0.1
      end
    end
  end

  def wait_until_element_exist(element)
    300.times do
      begin
        find(element, wait: 0.5)
        break
      rescue StandardError
        sleep 0.1
      end
    end
  end

  def specific_dropdown_select(element, text)
    drop = find(element)
    drop.find('option', text: text).select_option
  end

  def random_dropdown_select(element)
    drop = find(element)
    drop.all('option').sample.select_option
  end
end
