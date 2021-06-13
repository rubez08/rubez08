// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract BookCreation is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    //Represents Author with first name, last name, and author's address
    struct Author {
        string firstName;
        string lastName;
        address authorAddress;
    }
    // Represents number of Author accounts created
    uint numAuthors;
    // Authors address mapped to their author account
    mapping (address => Author) authors;


    // Represents a Book
    // Currently just title string
    // Unique BookId
    // Author's Address
    // Number of this book that have been minted
    struct Book {
        string title;
        uint book_id;
        address authorAddress;
        uint numMinted;
    }
    // Represents number of Books submitted
    uint numBooks;
    // BookId mapped to the Book it represents
    mapping (uint => Book) books;

    // Only the author who submitted this book
    modifier onlyBookOwner(uint book_id) {
        require(
            msg.sender == books[book_id].authorAddress,
            "Only the author can mint their book."
        );
        _;
    }

    // Only addresses that have created an Author account
    modifier onlyAuthors(address author) {
        require(
            authors[msg.sender].authorAddress != address(0x0),
            "Only Authors can publish a book on The Literary Block"
        );
        _;
    }

    // Only addresses who haven't yet created an Author account
    modifier onlyNonAuthors(address author) {
        require(
            authors[msg.sender].authorAddress == address(0x0),
            "You are already an author!"
        );
        _;
    }

    // Constructs ERC721 "Book" token collection with symbol "TLB"
    // Inital number of books and authors is 0
    constructor() ERC721("Book", "TLB"){
        numBooks = 0;
        numAuthors = 0;

    }
    // Only addresses who have not created an Author account can call this function
    // Creates new Author account at this address in the authors mapping
    // Takes a first name and last name input and sets this as Authors name
    //    also sets Author address
    // One more author added to numAuthor
    // Returns newAuthor
    function becomeAuthor(string calldata firstName, string calldata lastName) external onlyNonAuthors(msg.sender) returns (Author memory){
        Author storage newAuthor = authors[msg.sender];
        newAuthor.firstName = firstName;
        newAuthor.lastName = lastName;
        newAuthor.authorAddress = msg.sender;
        numAuthors = numAuthors++;
        return newAuthor;
    }
    
    // Only addresses who HAVE creaded an Author account can call this function
    // Adds one book to numBooks
    // Creates new Book with book_id: numBooks mapped to this new book
    // Adds title, book_id, authorAddress and sets number of books minted to 0
    // Returns newBook
    function createBook(string calldata title) external onlyAuthors(msg.sender) returns (Book memory) {
        numBooks = numBooks++;
        Book storage newBook = books[numBooks];
        newBook.title = title;
        newBook.book_id = numBooks;
        newBook.authorAddress = msg.sender;
        newBook.numMinted = 0;
        books[numBooks] = newBook;
        return newBook;
    }

    // *WIP*
    // Currently just:
    // Increments _tokenIds
    // Adds one to the numMinted variable in relevent Book
    // Mints a new ERC721 NFT Token "TLB"
    function mintBook(address author, uint book_id) external onlyBookOwner(book_id) returns (uint256){
        _tokenIds.increment();
        Book memory bookToBeMinted = books[book_id];
        bookToBeMinted.numMinted = bookToBeMinted.numMinted++;



        uint newBookId = _tokenIds.current();
        _safeMint(author, newBookId);
    }
}