require_relative './app_test_base'

class SocialSharingTest < AppTestBase
  test 'social sharing button and modal dialog should work as expected' do
    # arrange.
    visit DEMO_URL

    # act.
    btn_social_sharing = find(:css, App::Selectors::MainHeader.btn_social_sharing)
    btn_social_sharing.click

    ALL_SCREENS.each do |screen_size|
      # assert.
      resize_window_to(screen_size)

      modal_dialog = find(:css, '#modal-social-sharing')
      assert_modal_dialog_loads_successfully(modal_dialog, 'Share This Profile')
      within(modal_dialog) do
        buttons = all(:css, '.addthis_inline_share_toolbox .at-share-btn-elements a')
        assert_equal(SOCIAL_SHARING_BUTTONS.count, buttons.count)

        if MEDIUM_TO_LARGE_SCREENS.include?(screen_size)
          labels = all(:css, '.addthis_inline_share_toolbox .at-share-btn-elements a .at-label')
          labels.each do |label|
            assert(SOCIAL_SHARING_BUTTONS.include?(label.text))
          end
        end
      end
    end
  end
end
