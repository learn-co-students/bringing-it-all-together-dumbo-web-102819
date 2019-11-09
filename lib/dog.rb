class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        DB[:conn].execute(
            "CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )"
        )
    end

    def self.drop_table
        DB[:conn].execute(
            "DROP TABLE dogs"
        )
    end

    def save
        if self.id
            self.update
        else
            DB[:conn].execute(
                "INSERT INTO dogs (name, breed)
                VALUES ( ?, ? )", [self.name, self.breed]
            )
            self.id = DB[:conn].execute(
                "SELECT last_insert_rowid() FROM dogs"
            )[0][0]
        end
        self
    end

    def update
        DB[:conn].execute(
            "UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?", [self.name, self.breed, self.id]
        )
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        row = DB[:conn].execute(
            "SELECT * FROM dogs
            WHERE id = ?", id
        )[0]
        Dog.new_from_db(row)
    end

    def self.find_or_create_by(name:, breed:)
        row = DB[:conn].execute(
            "SELECT * FROM dogs
            WHERE name = ? AND breed = ?", [name, breed]
        )
        if row.empty?
            Dog.create(name: name, breed: breed)
        else
            Dog.new_from_db(row[0])
        end
    end

    def self.find_by_name(name)
        row = DB[:conn].execute(
            "SELECT * FROM dogs
            WHERE name = ?", name
        )[0]
        Dog.new_from_db(row)
    end
end