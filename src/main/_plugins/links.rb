#!/bin/bash
#
# Copyright (c) 2012-2017 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#   Codenvy, S.A. - initial API and implementation
#

module Reading
  class Generator < Jekyll::Generator
    def generate(site)
      begin
          docs = site.docs_to_write
          entries = {}
          collections = {}
          
          site.collections["docs"].filtered_entries.each do |entry|
            page = ""
            site.config["defaults"].each do |default|
                scope = default["scope"]
                path = scope["path"]
                full_path = "_docs/" + entry
                if full_path.include? path
                    value = default["values"]
                    categories = value["categories"]
                    categories.each do |category|
                        page=page+"/"+category
                    end
                    page=page+"/"
                end
                if full_path.include? "assets/"
                    image_name = entry.split('/').pop
                    collections[image_name]="/docs/"+entry
                end
            end
            
            entries[entry]=page 
          end
          
          site.config["collections"].each do |collection|
            if collection[0] != "posts"
              collections=collections.merge(get_col(site,collection[0],entries))
            end
          end     
          #puts collections
          site.config["links"] = collections
      rescue 
          red = "\033[0;31m"
          puts red + "Jekyll> There is an error in the ruby plugin file _plugins/links.rb." 
          puts red + "Jekyll> Check collection files such ass 'docs.yml' and 'tutorials.yml' under _data/ folder are formatted correctly."
          puts ""
          raise
      end
    end
    def get_col(site,col_name, entries)
        collections = {}
        hash1 = site.data
        hash1.each do |hash2|
            hash3 = hash1[col_name]
            hash3.each do |hash4|
                
                files = hash4[col_name]                
                files.each do |file|
                    parse = file.split('-')
                    parse.shift
                    parse = parse.join('-')
                    entries.keys.any? {|k| 
                        if k.include? file 
                            collections[file]=entries[k]+parse+"/index.html"
                        end
                        }
                end
            end
        end
        return collections
    end
  end
end
