# -*- coding: utf-8 -*-
class HatenaOAuth

  # cache access via instance variable
  def access
    @access ||= HatenaOAuth.access
    # HatenaOAuth.access
  end

  def self.access
    access_token = OAuth::AccessToken.from_hash(consumer,
                                                oauth_token: $secret.hatena.oauth_token,
                                                oauth_token_secret: $secret.hatena.oauth_token_secret)
    return access_token
  end

  def edit_get(eid)
    res = access.get "http://b.hatena.ne.jp/atom/edit/#{eid}"
    return res if res.code.to_i != 200
#    x = Nokogiri::XML res.body
    return Hash.from_libxml(res.body)
#    names = x.child.children.map(&:name).uniq
#    hash = {}
#    names.map{|s| x.child.children.search(s) }.reject(&:blank?).map{|r| hash[r.first.name.to_sym] = mapper(r) }
#    hash
  end

  def edit_put(eid, request_xml)
    access.put "http://b.hatena.ne.jp/atom/edit/#{eid}", request_xml
  end

  private
  def self.consumer
    consumer = OAuth::Consumer.new($secret.hatena.consumer_key, $secret.hatena.consumer_secret,
                                   request_token_path: $secret.hatena.request_token_url,
                                   authorize_path: $secret.hatena.authorize_url,
                                   access_token_path: $secret.hatena.access_token_url)
    return consumer
  end

#  def mapper(node)
#    case node
#    when Nokogiri::XML::Element
#      nil
#    when Nokogiri::XML::NodeSet
#      case node.count
#      when 0
#        return nil
#      when 1
#        node.text.strip
#      else
#        node.map{|n| mapper(n)}
#      end
#    end
#  end
end


# https://gist.github.com/343311 ... updated cuz it's 2 years ago
class Hash
  class << self
    def from_libxml(xml)
      begin
        result = Nokogiri::XML(xml)
        return { result.root.name.to_s.to_sym => xml_node_to_hash(result.root)}
      rescue Exception => e
        # raise your custom exception here
      end
    end

    def xml_node_to_hash(node)
      # If we are at the root of the document, start the hash
      if node.element?
        if node.children.present?
          result_hash = {}

          node.children.each do |child|
            result = xml_node_to_hash(child)

            if child.name == "text"
              if !child.next_element.present? and !child.previous_element.present?
                return result
              end
            elsif result_hash[child.name.to_sym]
              if result_hash[child.name.to_sym].is_a?(Object::Array)
                result_hash[child.name.to_sym] << result
              else
                result_hash[child.name.to_sym] = [result_hash[child.name.to_sym]] << result
              end
            else
              result_hash[child.name.to_sym] = result
            end
          end
          return result_hash
        elsif node.attributes.present?
          # TODO: get link node...
          # node.attributes.each_pair do |k,v|
          #   result_hash[node.name.to_sym] ||= {}
          #   result_hash[node.name.to_sym][k.to_sym] = v
          # end
        else
          return nil
        end
      else
        return node.content.to_s
      end
    end
  end
end
