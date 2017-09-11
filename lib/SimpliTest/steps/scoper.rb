require 'axe/cucumber/step_definitions'

# :nocov:
# Single-line step scoper
When /^(.*) within(?: the| an?)? (.*)$/ do |step_def, parent|
  selector, selector_type = selector_for(parent)
  patiently do
    if selector_type == 'xpath'
      within(:xpath, selector) do
        step step_def
      end
    elsif selector_type == 'css'
      within(:css, selector) do
        step step_def
      end
    else
      with_scope(parent) { step step_def }
    end
  end
end

# Multi-line step scoper
When /^(.*) within(?: the| an?)? (.*):$/ do |step_def, parent, table_or_string|
  selector, selector_type = selector_for(parent)
  patiently do
    if selector_type == 'xpath'
      within(:xpath, xpath) do
        step "#{step_def}:", table_or_string
      end
    else
      with_scope(parent) { step "#{step_def}:", table_or_string }
    end
  end
end
# :nocov:

# Execute step in the last opened window
When /^(.*) in the new window$/ do |step_def|
  change_window 'last'
  step step_def
end

