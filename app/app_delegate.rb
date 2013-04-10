class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    true
  end

    # CoreData
  def managedObjectContext
    @managedObjectContext ||= begin
      applicationName = NSBundle.mainBundle.infoDictionary.objectForKey("CFBundleName")

      documentsDirectory = NSFileManager.defaultManager.URLsForDirectory(NSDocumentDirectory, inDomains: NSUserDomainMask).lastObject;
      storeURL = documentsDirectory.URLByAppendingPathComponent("#{applicationName}.sqlite")

      error_ptr = Pointer.new(:object)
      options   = {
          NSMigratePersistentStoresAutomaticallyOption => true,
          NSInferMappingModelAutomaticallyOption       => true
      }
      unless persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: storeURL, options: options, error: error_ptr)
        raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
      end

      context                            = NSManagedObjectContext.alloc.init
      context.persistentStoreCoordinator = persistentStoreCoordinator

      context
    end
  end

  def managedObjectModel
    @managedObjectModel ||= begin
      model = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle]).mutableCopy

      model.entities.each do |entity|
        begin
          Kernel.const_get(entity.name)
          entity.setManagedObjectClassName(entity.name)

        rescue NameError
          entity.setManagedObjectClassName("Model")
        end
      end

      model
    end
  end

  def persistentStoreCoordinator
    @coordinator ||= NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(managedObjectModel)
  end
end
