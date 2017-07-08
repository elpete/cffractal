component extends="testbox.system.BaseSpec" {

    function run() {
        describe( "all the pieces working together", function() {
            beforeEach( function() {
                variables.dataSerializer = new cffractal.models.serializers.DataSerializer();
                variables.fractal = new cffractal.models.Manager( dataSerializer, dataSerializer );
            } );

            describe( "converting models", function() {
                describe( "converting items", function() {
                    it( "with a callback transformer", function() {
                        var book = new tests.resources.Book( {
                            id = 1,
                            title = "To Kill a Mockingbird",
                            year = "1960"
                        } );
                        var resource = fractal.item( book, function( book ) {
                            return {
                                "id" = book.getId(),
                                "title" = book.getTitle(),
                                "year" = book.getYear()
                            };
                        } );

                        var scope = fractal.createData( resource );
                        expect( scope.convert() ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1}} );
                    } );

                    it( "with a custom transformer", function() {
                        var book = new tests.resources.Book( {
                            id = 1,
                            title = "To Kill a Mockingbird",
                            year = "1960"
                        } );

                        var resource = fractal.item( book, new tests.resources.BookTransformer( fractal ) );

                        var scope = fractal.createData( resource );
                        expect( scope.convert() ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1}} );
                    } );

                    it( "can use a special serializer for a resource", function() {
                        var book = new tests.resources.Book( {
                            id = 1,
                            title = "To Kill a Mockingbird",
                            year = "1960"
                        } );

                        var resource = fractal.item( book, new tests.resources.BookTransformer( fractal ) );
                        resource.setSerializer( new cffractal.models.serializers.SimpleSerializer() );

                        var scope = fractal.createData( resource );
                        expect( scope.convert() ).toBe( {"year":1960,"title":"To Kill a Mockingbird","id":1} );
                    } );

                    describe( "includes", function() {
                        it( "ignores includes by default", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 )
                                } )
                            } );

                            var resource = fractal.item( book, new tests.resources.BookTransformer( fractal ) );

                            var scope = fractal.createData( resource );
                            expect( scope.convert() ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1}} );
                        } );

                        it( "can parse an item with an includes", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 )
                                } )
                            } );

                            var resource = fractal.item( book, new tests.resources.BookTransformer( fractal ) );

                            var scope = fractal.createData( resource = resource, includes = "author" );
                            expect( scope.convert() ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1,"author":{"data":{"name":"Harper Lee"}}}} );
                        } );

                        it( "can parse an item with a default includes", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 )
                                } )
                            } );

                            var resource = fractal.item( book, new tests.resources.DefaultIncludesBookTransformer( fractal ) );

                            var scope = fractal.createData( resource );
                            expect( scope.convert() ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1,"author":{"data":{"name":"Harper Lee"}}}} );
                        } );

                        it( "can use a special serializer for an include", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 )
                                } )
                            } );

                            var resource = fractal.item( book, new tests.resources.SpecializedSerializerBookTransformer( fractal ) );

                            var scope = fractal.createData( resource );
                            expect( scope.convert() ).toBe( {"data":{"year":1960,"title":"To Kill a Mockingbird","id":1,"author":{"name":"Harper Lee"}}} );
                        } );

                        it( "can parse an item with a nested includes", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 ),
                                    country = new tests.resources.Country( {
                                        id = 1,
                                        name = "United States"
                                    } )
                                } )
                            } );

                            var resource = fractal.item( book, new tests.resources.BookTransformer( fractal ) );

                            var scope = fractal.createData( resource, "author,author.country" );
                            var expectedData = {
                                "data" = {
                                    "year" = 1960,
                                    "title" = "To Kill a Mockingbird",
                                    "id" = 1,
                                    "author" = {
                                        "data" = {
                                            "name" = "Harper Lee",
                                            "country" = {
                                                "data" = {
                                                    "id" = 1,
                                                    "name" = "United States"
                                                }
                                            }
                                        }
                                    }
                                }
                            };
                            expect( scope.convert() ).toBe( expectedData );
                        } );

                        it( "can automatically includes the parent when grabbing a nested include", function() {
                            var book = new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960",
                                author = new tests.resources.Author( {
                                    id = 1,
                                    name = "Harper Lee",
                                    birthdate = createDate( 1926, 04, 28 ),
                                    country = new tests.resources.Country( {
                                        id = 1,
                                        name = "United States"
                                    } )
                                } )
                            } );

                            var resource = fractal.item( book, new tests.resources.BookTransformer( fractal ) );

                            var scope = fractal.createData( resource, "author.country" );
                            var expectedData = {
                                "data" = {
                                    "year" = 1960,
                                    "title" = "To Kill a Mockingbird",
                                    "id" = 1,
                                    "author" = {
                                        "data" = {
                                            "name" = "Harper Lee",
                                            "country" = {
                                                "data" = {
                                                    "id" = 1,
                                                    "name" = "United States"
                                                }
                                            }
                                        }
                                    }
                                }
                            };
                            expect( scope.convert() ).toBe( expectedData );
                        } );
                    } );
                } );

                describe( "converting collections", function() {
                    it( "with a callback transformer", function() {
                        var books = [
                            new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960"
                            } ),
                            new tests.resources.Book( {
                                id = 2,
                                title = "A Tale of Two Cities",
                                year = "1859"
                            } )
                        ];
                        var resource = fractal.collection( books, function( book ) {
                            return {
                                "id" = book.getId(),
                                "title" = book.getTitle(),
                                "year" = book.getYear()
                            };
                        } );

                        var scope = fractal.createData( resource );
                        expect( scope.convert() ).toBe( {"data":[{"year":1960,"title":"To Kill a Mockingbird","id":1},{"year":1859,"title":"A Tale of Two Cities","id":2}]} );
                    } );

                    it( "with a custom transformer", function() {
                        var books = [
                            new tests.resources.Book( {
                                id = 1,
                                title = "To Kill a Mockingbird",
                                year = "1960"
                            } ),
                            new tests.resources.Book( {
                                id = 2,
                                title = "A Tale of Two Cities",
                                year = "1859"
                            } )
                        ];

                        var resource = fractal.collection( books, new tests.resources.BookTransformer( fractal ) );

                        var scope = fractal.createData( resource );
                        expect( scope.convert() ).toBe( {"data":[{"year":1960,"title":"To Kill a Mockingbird","id":1},{"year":1859,"title":"A Tale of Two Cities","id":2}]} );
                    } );

                    describe( "pagination", function() {
                        it( "returns pagination data in a meta field", function() {
                            var books = [
                                new tests.resources.Book( {
                                    id = 1,
                                    title = "To Kill a Mockingbird",
                                    year = "1960"
                                } ),
                                new tests.resources.Book( {
                                    id = 2,
                                    title = "A Tale of Two Cities",
                                    year = "1859"
                                } )
                            ];

                            var resource = fractal.collection( books, new tests.resources.BookTransformer( fractal ) );
                            resource.setPagingData( { "maxrows" = 50, "page" = 2, "pages" = 3, "totalRecords" = 112 } );

                            var scope = fractal.createData( resource );
                            expect( scope.convert() ).toBe( {
                                "data": [
                                    {
                                        "id": 1,
                                        "title": "To Kill a Mockingbird",
                                        "year": 1960
                                    },
                                    {
                                        "id": 2,
                                        "title": "A Tale of Two Cities",
                                        "year": 1859
                                    }
                                ],
                                "meta": {
                                    "pagination": {
                                        "maxrows": 50,
                                        "page": 2,
                                        "pages": 3,
                                        "totalRecords": 112
                                    }
                                }
                            } );
                        } );
                    } );
                } );
            } );
        } );
    }

}