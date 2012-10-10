module OgoneRails

  module Helpers
    extend self
        
    def ogone_form_tag options={}
      OgoneRails::mode == "live" ? action = OgoneRails::LIVE_SERVICE_URL : action = OgoneRails::TEST_SERVICE_URL
      
      @form = Form.new(action, options)
      
      form_content = yield(form_content)
      
      output = @form.form_tag
      output << form_content
      output << "\n</form>"#.html_safe
      
      # block.methods
      output.html_safe
    end
    
    
    def ogone_fields options={}
      @hash = StringToHash.new
      
      # Required values
      add_ogone_parameter('PSPID', OgoneRails::pspid)
      add_ogone_parameter('currency', OgoneRails::currency)
      add_ogone_parameter('language', OgoneRails::language)
      
      options_index = {
        # General params
        :order_id           => 'orderID',
        :amount             => 'amount',
        :customer_name      => 'CN',
        :customer_email     => 'EMAIL',
        :customer_address   => 'owneraddress',
        :customer_zip       => 'ownerZIP',
        :customer_city      => 'ownertown',
        :customer_country   => 'ownercty',
        :customer_phone     => 'ownertelno',
        # Feedback url's    
        :accept_url         => 'accepturl',
        :decline_url        => 'declineurl',
        :exception_url      => 'exceptionurl',
        :cancel_url         => 'cancelurl',
        # Look and feel     
        :title              => 'TITLE',
        :bg_color           => 'BGCOLOR',
        :text_color         => 'TXTCOLOR',
        :table_bg_color     => 'TBLBGCOLOR',
        :table_text_color   => 'TBLTXTCOLOR',
        :button_bg_color    => 'BUTTONBGCOLOR',
        :button_text_color  => 'BUTTONTXTCOLOR',
        :font_family        => 'FONTTYPE',
        :logo               => 'LOGO'       
      }
      
      # Optional values
      options.each do |option, value|        
        if options_index.key?(option)
          value = (value.to_f * 100).to_i if option == :amount # amount in cents
          add_ogone_parameter(options_index[option], value)
        else
          add_ogone_parameter(option.to_s, value)
        end
      end
      
      # Shasign
      @form.add_input('SHASign', @hash.generate_sha_in)
      
      # get form_fields
      @form.form_fields
    end

    def ogone_form options={}, html={}
      ogone_form_tag(html) do
        output = ogone_fields(options)
        output << "\t<input type='submit' value='ga verder naar ogones' id='submit2' name='submit2'>\n"
      end
    end
    
    private 
      
      # helper method to add params to Form and Hash
      def add_ogone_parameter name, value
        @form.add_input(name, value)
        @hash.add_parameter(name.to_s, value)
      end
  end
end