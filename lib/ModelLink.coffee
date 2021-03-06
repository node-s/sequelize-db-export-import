Sequelize = require('sequelize')
Q = require('q')
_ = require('lodash')

module.exports = (() ->
  class ModelLink
    constructor: (options) ->
      @opts = options
      @sequelize = sequelize = new Sequelize(options.database, options.user, options.password, options)
      @queryInterface = sequelize.getQueryInterface().QueryGenerator
      @models = {}

    # show all tabls
    showAllTables: () ->
      @sequelize.showAllSchemas().then (tables) =>
        return _.pluck(tables, "Tables_in_#{@opts.database}")

    # describe one table
    describeOneTable: (table) ->
      oneTable = {}
      @sequelize.query(@queryInterface.describeTableQuery(table), null, {
        raw: true
      }).then (fields) =>
        if fields.id
          fields.id.autoIncrement = true
          fields.id.primaryKey = true

        oneTable[table] = fields
        @models[table] = fields
        
        return oneTable

    # describe all tables
    describeAllTables: () ->
      deferred = Q.defer()
      self = @

      @showAllTables().then (tables) ->
        promises = []

        tables.forEach (table) ->
          console.log table
          promises.push(self.describeOneTable(table))

        Q.all(promises).then (allTables) ->
          deferred.resolve(self.models)

      deferred.promise
          
)()
