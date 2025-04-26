import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/models/category_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/categories_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_text_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({super.key});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late final _nameController = TextEditingController(text: _category.name);
  late final _descriptionController = TextEditingController(
    text: _category.description,
  );
  bool _isLoading = false;
  Category _category = Category.none;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final category = ModalRoute.of(context)!.settings.arguments as Category;
      _fetchCategory(category.id);
    });
  }

  void _onConfirmPressed(BuildContext context) async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "All fields are required to fill",
        alertType: AlertBannerType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newCategory = await CategoriesApi.put(
      id: _category.id,
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (!context.mounted) {
      return;
    }

    if (newCategory != Category.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully edit the category. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to edit the category.",
        alertType: AlertBannerType.error,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _fetchCategory(int categoryId) async {
    _category = await CategoriesApi.getSingleCategory(categoryId);
    setState(() {
      _nameController.text = _category.name;
      _descriptionController.text = _category.description;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.lightGrey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                HeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(label: 'Edit Category'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Save',
                          cancelLabel: 'Cancel',
                          isLoading: _isLoading,
                          onConfirmPressed: () => _onConfirmPressed(context),
                          onCancelPressed: () => _onCancelPressed(context),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                NavbarWidget(),
              ],
            ),
            FloatingAddButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputTextWidget(
            label: 'Category ID',
            readOnly: true,
            textController: TextEditingController(
              text: _category.id.toString(),
            ),
            hint: "Category's ID",
          ),
          InputTextWidget(
            label: 'Name',
            textController: _nameController,
            hint: "Category's name",
          ),
          InputTextWidget(
            label: 'Description',
            textController: _descriptionController,
            hint: "Short description about the category",
            multiLine: true,
          ),
        ],
      ),
    );
  }
}
