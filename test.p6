use GraphQL::Class;

#| User class
class User does GraphQL::Class {
   has UInt $.id is ID is required; #= User Id
   has Str  $.name;                 #= The user name
   has Date $.birthday;             #= The birthday of the user
   has Bool $.status;               #= Is it active?

   method listusers(::?CLASS:U: Int :$start is ID = 0, Int :$count = 1 --> Positional[User]) is query {
   }

   method user(::?CLASS:U: Int :$id! is ID --> User) is query {
   }
}
say User.new: :42id, :name<Fernando>, :status;

say User.schema
