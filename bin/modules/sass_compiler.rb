# frozen_string_literal: true

require 'sassc'

# Private: Writes Sass (Scss) to css
class SassCompiler
  # Compiles SASS (SCSS) to css
  def self.compile
    sass = File.read('./bin/scss/main.css.scss')
    f = File.new('./bin/public/css/alternate.css', 'w+')
    f.write(SassC::Engine.new(sass, style: :compressed).render)
    f.close
  end
end
