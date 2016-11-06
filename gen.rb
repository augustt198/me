require 'haml'
require 'json'

include Haml::Helpers

init_haml_helpers

@data = JSON.parse(File.read("data.json"))
@items = []
def gen_node_html(node, root)
  haml_tag(:li, {style: "position: relative"}) do
    yield if block_given?
    if !root
      haml_tag(:div, {class: "angle"})
    end
    a = {id: "node-#{node["id"]}"}
    if node["type"] == "raw"
      haml_concat node["raw"]
    elsif node["type"] == "item"
      a[:href] = "javascript:item('#{node["id"]}')";
      haml_tag(:a, a) do
        haml_concat node["name"]
      end
      @items << node
    elsif node["type"] == "link"
      a[:href] = node["link"]
      a[:target] = "_blank"
      haml_tag(:a, a)  do
        haml_concat node["name"]
        haml_tag(:span, {class: "icon-external-link"})
      end
    elsif node["type"] == "dir"
      a[:href] = "javascript:foldNode('#{node["id"]}')";
      haml_tag(:a, a) do
        haml_concat node["name"] + "/"
      end
      attrs = {id: node["id"]}
      attrs[:style] = "display: none" if !root

      haml_tag(:ul, attrs) do
        node["children"].each_with_index do |e, i|
          gen_node_html(e, false) do
            if i < node["children"].length - 1
              haml_tag(:div, {class: 'treeside'})
            end
          end
        end
      end
    end
  end
end


template = File.read("index.haml")
engine   = Haml::Engine.new(template)
engine.options[:ugly] = true
File.write("index.html", engine.render(self))

puts "Finished!"
