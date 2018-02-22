# Autoload Rails Models

Psych::Visitors::ToRuby.prepend Module.new {
  def resolve_class(klass_name)
    klass_name && klass_name.safe_constantize || super
  end
}