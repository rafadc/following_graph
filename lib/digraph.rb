# This class handles the communication with Digraph to generate the image
class Digraph
  def generate_image(root_node, options)
    temp_file = Tempfile.new(['twitter_grahviz_file', '.dot'])
    temp_file.write(graph_string(root_node))
    temp_file.flush

    command = "dot #{temp_file.path} -o #{options[:output]} -Kdot -Tpng"
    puts "Invoking: #{command}"
    system command
  end

  private

  def graph_string(root_node)
    output = "digraph G {\n"
    output << "\t ratio=.3;\n"
    output << draw_node(root_node)
    output << "}\n"
    output
  end

  def draw_node(node)
    output = "\t#{node.name};\n"
    node.relations.each do |child|
      output << "\t#{node.name} -> #{child.name};\n"
      output << draw_node(child)
    end
    output
  end
end
