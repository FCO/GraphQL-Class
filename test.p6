use GraphQL::Class;

#| User class
class User does GraphQL::Class {
   has UInt $.id is ID is required; #= User Id
   has Str  $.name;                 #= The user name
   has Date $.birthday;             #= The birthday of the user
   has Bool $.status;               #= Is it active?

   method listusers(Int :$start is ID = 0, Int :$count = 1 --> Positional[User]) is query {
   }
}
say User.schema
