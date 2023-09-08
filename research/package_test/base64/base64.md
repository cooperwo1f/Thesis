# Base64

[Base64](https://developer.mozilla.org/en-US/docs/Glossary/Base64) is a way to encode information 
while not transmitting line breaks and other special characters that may be used in the transmission process.

[RFC 4648 algorithm](https://datatracker.ietf.org/doc/html/rfc4648)

The benefit of this is that the special characters can still be used to align the data without limiting 
what characters can actually be sent.

[ASCII encoding](https://www.ascii-code.com/) is an alternative to this that is less efficient.
Could be a good place to put in a decision matrix and go over more specific pros and cons.
