require './config/environment'

class App < Sinatra::Base
  set :views, Proc.new { File.join(root, "../views/") }

  get '/' do
    @emails = Email.all
    erb :'index'
  end

  get '/emails/new' do
    erb :'new'
  end

  post '/emails' do
    emails = params[:emails]

    emails.each do |email|
      mail = Mail.read(email[:tempfile])

      if mail.multipart?
        mail.parts.each do |part|
          if part.content_type.include?("text/html") && !part.multipart?
            Email.create(file_name: email[:filename], to: mail.to, from: mail.from[-1], subject: mail.subject, body: part.decoded)
          else
            part.parts.each do |inner_part|
              if inner_part.content_type.include?("text/html")
                Email.create(file_name: email[:filename], to: mail.to, from: mail.from[-1], subject: mail.subject, body: inner_part.decoded)
              end
            end
          end
        end
      else
        Email.create(file_name: email[:filename], to: mail.to, from: mail.from[-1], subject: mail.subject, body: mail.decoded)
      end
    end
    redirect to '/'
  end

  get '/emails/search' do
    erb :'search'
  end

  post '/emails/search' do
    search_terms = params[:input].split(", ")
    filter_from = params[:filter]

    emails = Email.all
    @emails_with_input = []

    emails.each do |email|
      # binding.pry
      if !filter_from.empty? && email.subject != nil
        if search_terms.all? { |word| email.body.downcase.include?(word.downcase) || email.file_name.downcase.include?(word.downcase) || email.subject.downcase.include?(word.downcase)} && !email.from.include?(filter_from)
          @emails_with_input << email
        end
      elsif !filter_from.empty?
        if search_terms.all? { |word| email.body.downcase.include?(word.downcase) || email.file_name.downcase.include?(word.downcase)} && !email.from.include?(filter_from)
          @emails_with_input << email
        end
      elsif !search_terms.empty? && email.subject != nil && email.body != nil && email.file_name != nil
        if search_terms.all? { |word| email.body.downcase.include?(word.downcase) || email.file_name.downcase.include?(word.downcase) || email.subject.downcase.include?(word.downcase)} #one of the emails doesn't have a subject so methods on it bring up an error
          @emails_with_input << email
        end
      elsif !search_terms.empty? && email.body != nil && email.file_name != nil
        if search_terms.all? { |word| email.body.downcase.include?(word.downcase) || email.file_name.downcase.include?(word.downcase)}
          @emails_with_input << email
        end
      end
    end

    erb :'results'
  end

  get '/emails/:id' do
    @email = Email.find_by_id(params[:id])
    erb :'/show'
  end

  delete '/emails/delete' do
    Email.destroy_all
    erb :'delete'
  end

end
